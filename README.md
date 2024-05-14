# GPT Command-line interface

Alternative solution is to use **free** AI models (Chat GPT) on the command line via the PowerShell module using the web version via Selenium for direct integration into the code.

Modules for working with **[Phind](https://github.com/Lifailon/gpt-cli/blob/rsa/Modules/Get-Phind/Get-Phind.psm1)**, **[LangChain](https://github.com/Lifailon/gpt-cli/blob/rsa/Modules/Get-LangChain/Get-LangChain.psm1)** and **[YandexGPT](https://github.com/Lifailon/gpt-cli/blob/rsa/Modules/Get-YaGPT/Get-YaGPT.psm1)** have been released. YaGPT has a probability of triggering captcha, Phind only works in window mode. Reading the contents of LangChain responses is done from Trace.

### Install

- To install all dependencies (browser Chromium and drivers latest version), use the command for deployment:

```PowerShell
Invoke-Expression(New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/Lifailon/Deploy-Selenium/rsa/Deploy-Selenium-Drivers.ps1")
```

- Download the [module directories](https://github.com/Lifailon/gpt-cli/tree/rsa/Modules) and place them in the default PowerShell modules directory, such as here: `$PSHOME\modules` or `$($Env:PSModulePath -split ";")[0]`.

### Request example:

![Image alt](https://github.com/Lifailon/gpt-cli/blob/rsa/Image/Example.gif)