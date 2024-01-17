# GPT-to-Code

Integrating free Web version of ChatGPT to PowerShell code. The modules based on **Selenium (without using API)**.

Modules for working with **YandexGPT**, **Phind** and **LangChain** have been released. YaGPT has a probability of triggering captcha, Phind only works in window mode. Reading the contents of LangChain responses is done from Trace.

### Parameters: 

- `Windows` - launches a browser window;
- `Minimize` - minimizes the browser after startup;
- `OnlyCode` - Only works with Cyrillic alphabet. Gives the response in code format only. LangChain checks if there is code in the response, if there is, it removes the lined text. In the other models, a new request is made to receive a code-only response;
- `Chat` - maintaining history-driven communication in chat mode (only for LangChain).

### Install

To install all dependencies (browser Chromium and drivers latest version), use the command for deployment:
```PowerShell
Invoke-Expression(New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/Lifailon/Deploy-Selenium/rsa/Deploy-Selenium-Drivers.ps1")
```

Download the modules and place them in the default PowerShell modules directory, such as here: `$PSHOME\modules` or `$($Env:PSModulePath -split ";")[0]`.

### Request example:

```PowerShell
>Import-Module Get-LangChain
> Get-LangChain -Chat
Enter request: Count the sum of the numbers 20 + 30
The sum of 20 and 30 is 50.
> Get-LangChain "Напиши PowerShell скрипт для создания TCP сокета" -OnlyCode

$ipAddress = "127.0.0.1"
$port = 8080

$tcpListener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse($ipAddress), $port)
$tcpListener.Start()

Write-Host "Listening for incoming connections on $ipAddress:$port"

$tcpClient = $tcpListener.AcceptTcpClient()
$networkStream = $tcpClient.GetStream()

$buffer = New-Object byte[] 1024
$bytesRead = $networkStream.Read($buffer, 0, $buffer.Length)
$data = [System.Text.Encoding]::ASCII.GetString($buffer, 0, $bytesRead)

Write-Host "Received data: $data"

$tcpClient.Close()
$tcpListener.Stop()
```