function Get-LangChain {
    <#
    .SYNOPSIS
    Module for free communication with model GPT without using API
    .DESCRIPTION
    Examples:
    Get-LangChain -Chat
    Get-LangChain "Посчитай сумму чисел: 22+33" -Window
    Get-LangChain "Write a PowerShell script to create a TCP socket"
    Get-LangChain "Напиши PowerShell скрипт для создания TCP сокета" -OnlyCode
    .LINK
    https://github.com/Lifailon/GPT-to-Code
    https://chat.langchain.com
    #>
    param (
        [Parameter(ValueFromPipeline)][string]$Text,
        [Switch]$Chat, # поддержание общения с учетом истории в режиме чата
        [Switch]$Window = $false, # открыть окно браузера
        [Switch]$Minimize = $false, # свернуть окно
        [Switch]$OnlyCode # возвращать только код
    )
    $url = "https://chat.langchain.com"
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
        # Проверяем, что url полностью загрузилась
        while ($null -eq $OutputTemp) {
            $OutputTemp = $Selenium.FindElements([OpenQA.Selenium.By]::ClassName("css-14j1d50"))[-1].Text
        }
        # Проверяем, что ответ получен полностью (статус кнопки)
        function Get-ButtonStatus {
            $Button_Status = $Selenium.FindElements([OpenQA.Selenium.By]::ClassName("css-1853zhr")).Text
            while ($Button_Status -match "Loading") {
                $Button_Status = $Selenium.FindElements([OpenQA.Selenium.By]::ClassName("css-1853zhr")).Text
            }
        }
        # Передаем текст запроса и получаем ответ
        function Get-GPT ($Text) {
            $InputText = $Selenium.FindElements([OpenQA.Selenium.By]::ClassName("css-qbuvt6"))
            $InputText.SendKeys("$Text")
            $InputText.SendKeys([OpenQA.Selenium.Keys]::Enter)
            Get-ButtonStatus
            $Selenium.FindElements([OpenQA.Selenium.By]::ClassName("css-79wky"))[0].Text
        }
        # Забираем ответ из новой вкладки Trace
        function Get-ViewTrace {
            # Фиксируем ID текущей вкладки
            $WH_Current = $Selenium.WindowHandles
            # Ищем View trace и открываем новую вкладку с трассировкой запроса
            $View_Trace = $Selenium.FindElements([OpenQA.Selenium.By]::ClassName("css-udpl07"))
            $View_Trace.Click()
            # Проверяем, что была открыта новая вкладка
            while ($Selenium.WindowHandles.Count -eq 1) {
                Start-Sleep 1
                $Count_Click += 1
                # Если была ошибка при нажатии на кнопку, фиксируем 5 секунд и нажимаем еще раз
                if ($Count_Click -eq 5) {
                    $Count_Click = 0
                    $View_Trace.Click()
                }
            }
            # Забираем ID второй вкладки
            $WH_Last =  $Selenium.WindowHandles -ne $WH_Current
            # Переключаемся на последнюю открытую вкладку
            $Selenium.SwitchTo().Window("$WH_Last") | Out-Null
            # Проверяем наличие Output
            $Check_Output = $Selenium.FindElements([OpenQA.Selenium.By]::ClassName("p-4"))[-1].Text.Length
            while ($Check_Output -le 1) {
                # Обновляем страницу
                $Selenium.Navigate().Refresh()
                Start-Sleep 1
                $Check_Output = $Selenium.FindElements([OpenQA.Selenium.By]::ClassName("p-4"))[-1].Text.Length
            }
            # Забираем содержимое ответа
            $Selenium.FindElements([OpenQA.Selenium.By]::ClassName("p-4"))[-1].Text
            # Закрываем текущую вкладку и возвращаемся на первую страницу
            $Selenium.Close()
            $Selenium.SwitchTo().Window($Selenium.WindowHandles[0]) | Out-Null
        }
        if ($Chat) {
            while ($true) {
                $Text = Read-Host "Enter request"
                if ($null -ne $Text) {
                    Get-GPT $Text | Out-Null
                    Get-ViewTrace
                }
                else {
                    break
                }
            }
        }
        else {
            Get-GPT $Text | Out-Null
            $OutputText = Get-ViewTrace
        }
        # Проверяем наличие тэгов с кодом и возвращаем только код
        if ($OnlyCode) {
            $Count = $Selenium.FindElements([OpenQA.Selenium.By]::TagName("Code")).Count
            while ($Count -eq 0) {
                Get-GPT "Ответь иначе" | Out-Null
                $Count = $Selenium.FindElements([OpenQA.Selenium.By]::TagName("Code")).Count
            }
            $OutputText = Get-ViewTrace
            # Удаляем лишний текст в начале каждой строки и пустые строки
            $OutputText -split "`n" -replace '^[а-яА-Я].+|```.+' | Where-Object {$_ -ne ""}
        }
        else {
            $OutputText
        }
    }
    finally {
        $Selenium.Close()
        $Selenium.Quit()
    }
}