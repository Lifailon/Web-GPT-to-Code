# Web-GPT-to-Code

Integrating free Web version of Chat GPT to PowerShell code. The modules based on **Selenium (without using API)**.

Currently, modules for working with **Yandex GPT** and **Phind** have been released. Phind only works in window mode. Currently looking for the most stable service. 

Parameters: 

- `Windows` - launches a browser window
- `Minimize` - minimizes the browser after startup
- `OnlyCode` - gives the response in code format only

To install all dependencies (browser Chromium and drivers latest version), use the command for deployment:
```PowerShell
Invoke-Expression(New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/Lifailon/Deploy-Selenium/rsa/Deploy-Selenium-Drivers.ps1")
```