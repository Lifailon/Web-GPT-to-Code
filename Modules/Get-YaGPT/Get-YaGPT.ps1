function Get-YaGPT {
    <#
    .SYNOPSIS
    Module for free communication with YandexGTP without using API
    .DESCRIPTION
    Examples:
    Get-YaGPT "Посчитай сумму чисел: 22+33" -Window
    Get-YaGPT "Исполняй роль интерпретатора PowerShell. Выведи результат команды без лишнего текста: Write-Host $(22+33)" -Window -Minimize
    Get-YaGPT "Напиши скрипт на языке PowerShell для создания TCP сокета"
    Get-YaGPT "Напиши скрипт на языке PowerShell для создания TCP сокета. Пожалуйста, предоставь только код в ответе." -OnlyCode
    .LINK
    https://github.com/Lifailon/GPT-to-Code
    https://ya.ru
    #>
    param (
        [Parameter(Mandatory,ValueFromPipeline)][string]$Text,
        [Switch]$Window = $false,
        [Switch]$Minimize = $false,
        [Switch]$OnlyCode
    )
    $url = "https://ya.ru/alisa_davay_pridumaem"
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
        while ($null -eq $OutputTemp) {
            $OutputTemp = $Selenium.FindElements([OpenQA.Selenium.By]::ClassName("markdown-text"))[-1].Text
        }
        # Передаем текст запроса
        $InputText = $Selenium.FindElements([OpenQA.Selenium.By]::ClassName("svelte-1p4h8hu"))
        $InputText = ($InputText | Where-Object ComputedAccessibleRole -eq generic)[1]
        $InputText.SendKeys("$Text")
        $InputText.SendKeys([OpenQA.Selenium.Keys]::Enter)
        # Проверяем, что ответ получен полностью (наличие кнопок ответа)
        function Get-ButtonCount {
            $Button_Count = $($Selenium.FindElements([OpenQA.Selenium.By]::ClassName("svelte-krb7a"))).Count
            $OutputText = $Selenium.FindElements([OpenQA.Selenium.By]::ClassName("markdown-text"))[-1].Text
            while ($Button_Count -eq 0) {
                $Button_Count = $($Selenium.FindElements([OpenQA.Selenium.By]::ClassName("svelte-krb7a"))).Count
            }
        }
        Get-ButtonCount
        # Завершаем, если ответ был направлен в поисковик или сработала captcha (изменился url)
        if ($Selenium.Url -ne $url) {
            Write-Error "Error url: $Output_Url"
            exit 1
        }
        # Забираем ответ
        else {
            $OutputText = $Selenium.FindElements([OpenQA.Selenium.By]::ClassName("markdown-text"))[-1].Text
        }
        # Проверяем на вхождение кириллицы в начале каждой строки, что бы получить ответ только в формате кода
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
                if (Get-LatinLetters $OutputText) {
                    $Button = $($Selenium.FindElements([OpenQA.Selenium.By]::ClassName("svelte-krb7a")) | Where-Object Text -Match "Ответь иначе")
                    $Button.Click()
                    Get-ButtonCount
                    $OutputText = $Selenium.FindElements([OpenQA.Selenium.By]::ClassName("markdown-text"))[-1].Text
                }
                else {
                    $OutputText
                    break
                }
            }
        }
        else {
            $Selenium.FindElements([OpenQA.Selenium.By]::ClassName("markdown-text"))[-1].Text
        }
    }
    finally {
        $Selenium.Close()
        $Selenium.Quit()
    }
}