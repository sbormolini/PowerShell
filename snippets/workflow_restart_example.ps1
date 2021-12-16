workflow Restart-LocalComputerWorkflow
{
    # create scheduled task
    Write-Output -InputObject "$(Get-Date -Format g) : Create Scheduled Task 'ResumeRestartWorkflow'"
    inlineScript 
    {
        $trigger = New-ScheduledTaskTrigger -AtStartup
        $command = 'Import-Module -Name PSWorkflow; Get-Job -Name "RestartWorkflow" | Where-Object { $_.State -eq "Suspended" } | Resume-Job'
        $bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
        $encodedCommand = [Convert]::ToBase64String($bytes)
        $action = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
                                        -Argument "-NoProfile -NoExit -EncodedCommand ${encodedCommand}"

        Register-ScheduledTask -TaskName "ResumeRestartWorkflow" `
                            -Action $action `
                            -Trigger $trigger `
                            -RunLevel Highest
    }

    Write-Output -InputObject "$(Get-Date -Format g) : Restart '$($env:COMPUTERNAME)'"
    Restart-Computer -Wait
    Start-Sleep -Seconds 15

    # remove scheduled task
    Write-Output -InputObject "$(Get-Date -Format g) : Remove Scheduled Task 'ResumeRestartWorkflow'"
    inlineScript 
    {
        Get-ScheduledTask -TaskName "ResumeRestartWorkflow" | Unregister-ScheduledTask -Confirm:$false
    }
}

# run workflow
Restart-LocalComputerWorkflow -JobName "RestartWorkflow"
