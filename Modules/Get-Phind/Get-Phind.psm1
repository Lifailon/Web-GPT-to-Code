function Get-Phind {
    <#
    .SYNOPSIS
    Module for free communication with ChatGTP without using API
    .DESCRIPTION
    Examples:
    Get-Phind "Посчитай сумму чисел: 22+33" -Window
    Get-Phind "Исполняй роль интерпретатора PowerShell. Выведи результат команды без лишнего текста: Write-Host $(22+33)" -Window -Minimize
    Get-Phind "Исполняй роль переводчика. Переведи текст на русский язык: Phind is an intelligent assistant for programmers. With Phind, you'll get the answer you're looking for in seconds instead of hours." -Window
    Get-Phind "Напиши скрипт на языке PowerShell для создания TCP сокета" -Window -OnlyCode
    .LINK
    https://github.com/Lifailon/GPT-to-Code
    https://www.phind.com
    #>
    param (
        [Parameter(Mandatory,ValueFromPipeline)][string]$Text,
        [Switch]$Window = $false,
        [Switch]$Minimize = $false,
        [Switch]$OnlyCode
    )
    $url = "https://www.phind.com/agent?home=true"
    $path = "$home\Documents\Selenium\"
    $log = "$path\ChromeDriver.log"
    $ChromeDriver = "$path\ChromeDriver.exe"
    $WebDriver = "$path\WebDriver.dll"
    $SupportDriver = "$path\WebDriver.Support.dll"
    $Chromium = (Get-ChildItem $path -Recurse | Where-Object Name -like chrome.exe).FullName
    Add-Type -Path $WebDriver
    Add-Type -Path $SupportDriver
    try {
        $ChromeOptions = New-Object OpenQA.Selenium.Chrome.ChromeOptions
        $ChromeOptions.BinaryLocation = $Chromium
        $ChromeOptions.AddArgument("start-maximized")
        $ChromeOptions.AcceptInsecureCertificates = $True
        if ($Window -eq $false) {
            $ChromeOptions.AddArgument("headless")
        }
        $ChromeDriverService = [OpenQA.Selenium.Chrome.ChromeDriverService]::CreateDefaultService($ChromeDriver)
        $ChromeDriverService.HideCommandPromptWindow = $True
        $ChromeDriverService.LogPath = $log
        $ChromeDriverService.EnableAppendLog = $False
        $ChromeDriverService.EnableVerboseLogging = $False
        $Selenium = New-Object OpenQA.Selenium.Chrome.ChromeDriver($ChromeDriverService, $ChromeOptions)
        $Selenium.Navigate().GoToUrl("$url")
        if ($Minimize -eq $true) {
            $Selenium.Manage().Window.Minimize()
        }
        # Проверяем, что мы можем прочитать первый стандартный ответ, значит url полностью загрузилась
        $Count = $($Selenium.FindElements([OpenQA.Selenium.By]::ClassName("fs-5")) | Where-Object {$_.Text.Length -ne 0}).Count
        while ($Count -eq 0) {
            $Count = $($Selenium.FindElements([OpenQA.Selenium.By]::ClassName("fs-5")) | Where-Object {$_.Text.Length -ne 0}).Count
        }
        # Передаем текст запроса
        $InputText = $Selenium.FindElements([OpenQA.Selenium.By]::Name("q"))
        $InputText.SendKeys("$Text")
        $InputText.SendKeys([OpenQA.Selenium.Keys]::Enter)
        # Проверяем, что ответ получен полностью (наличие кнопоки Continue)
        function Get-Continue {
            $Continue = $Selenium.FindElements([OpenQA.Selenium.By]::ClassName("btn-sm")) | Where-Object Text -eq "Continue"
            while ($Continue.Count -eq 0) {
                $Continue = $Selenium.FindElements([OpenQA.Selenium.By]::ClassName("btn-sm")) | Where-Object Text -eq "Continue"
            }
        }
        Get-Continue
        # Забираем ответ
        $OutputText = $($Selenium.FindElements([OpenQA.Selenium.By]::ClassName("fs-5")) | Where-Object {$_.Text.Length -ne 0})[1..100].Text
        # Если нужно вернуть только код, повторяем запрос
        function Get-LatinLetters {
            param(
                [string]$Text
            )
            foreach ($t in $($Text -split "\n")) {
                if ($t -match "^[а-яА-Я]+") {
                    $true
                    break
                }
            }
        }
        if ($OnlyCode) {
            while ($True) {
                # Проверяем ответ на вхождение кириллицы
                if (Get-LatinLetters $OutputText) {
                    # Фиксируем количество блоков ответа
                    $Count = $($Selenium.FindElements([OpenQA.Selenium.By]::ClassName("fs-5")) | Where-Object {$_.Text.Length -ne 0})[0..100].count
                    $Selenium.FindElements([OpenQA.Selenium.By]::Name("q")).SendKeys("Ответь иначе только код без лишнего текста описания")
                    $Selenium.FindElements([OpenQA.Selenium.By]::Name("q")).SendKeys([OpenQA.Selenium.Keys]::Enter)
                    Get-Continue
                    # Забираем ответ
                    $OutputText = $($Selenium.FindElements([OpenQA.Selenium.By]::ClassName("fs-5")) | Where-Object {$_.Text.Length -ne 0})[$($count+1)..100].Text
                }
                else {
                    break
                }
            }
        }
        $OutputText
    }
    finally {
        $Selenium.Close()
        $Selenium.Quit()
    }
}