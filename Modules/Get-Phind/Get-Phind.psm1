function Get-Phind {
    <#
    .SYNOPSIS
    Module for free communication with ChatGTP without using API
    .DESCRIPTION
    Examples:
    Get-Phind "Посчитай сумму чисел: 22+33" -Window
    Get-Phind "Переведи текст на русский язык: What you do with that power is entirely up to you"
    Get-Phind "Исполняй роль интерпретатора PowerShell. Выведи результат команды без лишнего текста: Write-Host $(22+33)" -Window -Minimize
    Get-Phind "Исполняй роль переводчика. Переведи текст на русский язык: Phind is an intelligent assistant for programmers. With Phind, you'll get the answer you're looking for in seconds instead of hours." -Window
    Get-Phind "Напиши скрипт на языке PowerShell для создания TCP сокета" -Window -OnlyCode
    .LINK
    https://github.com/Lifailon/gpt-cli
    https://www.phind.com
    #>
    param (
        [Parameter(Mandatory,ValueFromPipeline)][string]$Text,
        [Switch]$Window = $false,
        [Switch]$Minimize = $false
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
        Start-Sleep 2
        # Лог
        $($Selenium.FindElements([OpenQA.Selenium.By]::ClassName("fs-5")) | Where-Object {$_.Text.Length -ne 0}).Text
        # Проверяем, что ответ получен полностью (отсутствие кнопоки Stop)
        function Get-Continue {
            $Continue = $Selenium.FindElements([OpenQA.Selenium.By]::TagName("button")) | Where-Object Text -Match "Stop"
            while ($null -ne $Continue) {
                $Continue = $Selenium.FindElements([OpenQA.Selenium.By]::TagName("button")) | Where-Object Text -Match "Stop"
            }
        }
        # Проходим проверку (если требуется)
        $Checker = $Selenium.FindElements([OpenQA.Selenium.By]::TagName("button")) | Where-Object Text -match "Continue"
        if ($null -ne $Checker) {
            $Checker.Click()
            $Check = $true
            Start-Sleep 2
        }
        Get-Continue
        # Забираем ответ
        if ($Check) {
            $OutputText = $($Selenium.FindElements([OpenQA.Selenium.By]::ClassName("fs-5")) | Where-Object {$_.Text.Length -ne 0}).Text[2..1000]
        } else {
            $OutputText = $($Selenium.FindElements([OpenQA.Selenium.By]::ClassName("fs-5")) | Where-Object {$_.Text.Length -ne 0}).Text[1..1000]
        }
        Continue $OutputText
    }
    finally {
        $Selenium.Close()
        $Selenium.Quit()
    }
}