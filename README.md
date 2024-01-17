# GPT-to-Code

Integrating free Web version of ChatGPT to PowerShell code. The modules based on **Selenium (without using API)**.

Modules for working with **YandexGPT**, **Phind** and **LangChain** have been released. YaGPT has a probability of triggering captcha, Phind only works in window mode. Reading the contents of LangChain responses is done from Trace.

### Parameters: 

- `Windows` - launches a browser window;
- `Minimize` - minimizes the browser after startup;
- `OnlyCode` - gives the response in code format only. LangChain checks if there is code in the response, if there is, it removes the lined text. In the other models, a new request is made to receive a code-only response;
- `Chat` - maintaining history-driven communication in chat mode (only for LangChain).

### Install

To install all dependencies (browser Chromium and drivers latest version), use the command for deployment:
```PowerShell
Invoke-Expression(New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/Lifailon/Deploy-Selenium/rsa/Deploy-Selenium-Drivers.ps1")
```

Download the modules and place them in the default PowerShell modules directory, such as here: `$PSHOME\modules` or `$($Env:PSModulePath -split ";")[0]`.

### Request example:

```PowerShell
Import-Module Get-LangChain
Get-LangChain -Chat
Get-LangChain "Write a PowerShell script to create a TCP socket" -OnlyCode
```