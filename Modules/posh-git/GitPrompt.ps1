# Inspired by Mark Embling
# http://www.markembling.info/view/my-ideal-powershell-prompt-with-git-integration

$global:GitPromptSettings = New-Object PSObject -Property @{
    # $ce = [char]0x2731
    DefaultForegroundColor                      = $Host.UI.RawUI.ForegroundColor

    BeforeText                                  = ' ['
    BeforeForegroundColor                       = [ConsoleColor]::Yellow
    BeforeBackgroundColor                       = [ConsoleColor]::DarkBlue

    DelimText                                   = ' |'
    DelimForegroundColor                        = [ConsoleColor]::Yellow
    DelimBackgroundColor                        = [ConsoleColor]::DarkBlue

    AfterText                                   = ' ]'
    AfterForegroundColor                        = [ConsoleColor]::Yellow
    AfterBackgroundColor                        = [ConsoleColor]::DarkBlue

    LocalDefaultStatusSymbol                    = $null
    LocalDefaultStatusForegroundColor           = [ConsoleColor]::DarkGreen
    LocalDefaultStatusForegroundBrightColor     = [ConsoleColor]::Green
    LocalDefaultStatusBackgroundColor           = [ConsoleColor]::DarkBlue

    LocalWorkingStatusSymbol                    = [char]0xf02d #"!"
    LocalWorkingStatusForegroundColor           = [ConsoleColor]::DarkRed
    LocalWorkingStatusForegroundBrightColor     = [ConsoleColor]::Red
    LocalWorkingStatusBackgroundColor           = [ConsoleColor]::DarkBlue

    LocalStagedStatusSymbol                     = '~'
    LocalStagedStatusForegroundColor            = [ConsoleColor]::Cyan
    LocalStagedStatusBackgroundColor            = [ConsoleColor]::DarkBlue

    BranchIdenticalStatusToSymbol               = [char]0xe0a0 #0x2261 Three horizontal lines
    BranchIdenticalStatusToForegroundColor      = [ConsoleColor]::Green
    BranchIdenticalStatusToBackgroundColor      = [ConsoleColor]::DarkBlue

    BranchAheadStatusSymbol                     = [char]0x2191 # Up arrow
    BranchAheadStatusForegroundColor            = [ConsoleColor]::Cyan
    BranchAheadStatusBackgroundColor            = [ConsoleColor]::DarkBlue

    BranchBehindStatusSymbol                    = [char]0x2193 # Down arrow
    BranchBehindStatusForegroundColor           = [ConsoleColor]::Red
    BranchBehindStatusBackgroundColor           = [ConsoleColor]::DarkBlue

    BranchBehindAndAheadStatusSymbol            = [char]0x2195 # Up & Down arrow
    BranchBehindAndAheadStatusForegroundColor   = [ConsoleColor]::Yellow
    BranchBehindAndAheadStatusBackgroundColor   = [ConsoleColor]::DarkBlue

    BeforeIndexText                             = ""
    BeforeIndexForegroundColor                  = [ConsoleColor]::DarkGreen
    BeforeIndexForegroundBrightColor            = [ConsoleColor]::Green
    BeforeIndexBackgroundColor                  = [ConsoleColor]::DarkBlue

    IndexForegroundColor                        = [ConsoleColor]::DarkGreen
    IndexForegroundBrightColor                  = [ConsoleColor]::Green
    IndexBackgroundColor                        = [ConsoleColor]::DarkBlue

    WorkingForegroundColor                      = [ConsoleColor]::DarkRed
    WorkingForegroundBrightColor                = [ConsoleColor]::Red
    WorkingBackgroundColor                      = [ConsoleColor]::DarkBlue

    ShowStatusWhenZero                          = $true

    AutoRefreshIndex                            = $true

    EnablePromptStatus                          = !$Global:GitMissing
    EnableFileStatus                            = $true
    RepositoriesInWhichToDisableFileStatus      = @( ) # Array of repository paths
    DescribeStyle                               = ''

    # EnableWindowTitle                           = 'posh~git ~ '

    Debug                                       = $false

    BranchNameLimit                             = 0
    TruncatedBranchSuffix                       = '...'
}

$currentUser = [Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdminProcess = $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

$adminHeader = if ($isAdminProcess) { 'Administrator: ' } else { '' }

$WindowTitleSupported = $true
if (Get-Module NuGet) {
    $WindowTitleSupported = $false
}

function Write-Prompt($Object, $ForegroundColor, $BackgroundColor = -1) {
    if ($BackgroundColor -lt 0) {
        Write-Host $Object -NoNewLine -ForegroundColor $ForegroundColor
    } else {
        Write-Host $Object -NoNewLine -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
    }
}

function Format-BranchName($branchName){
    $s = $global:GitPromptSettings

    if($s.BranchNameLimit -gt 0 -and $branchName.Length -gt $s.BranchNameLimit)
    {
        $branchName = "{0}{1}" -f $branchName.Substring(0,$s.BranchNameLimit), $s.TruncatedBranchSuffix
    }

    return $branchName
}

function Write-GitStatus($status) {
    $cp = [char]0x271a
    $cm = [char]0x2710
    $cd = [char]0x2717
    $ce = [char]0x2731
    $s = $global:GitPromptSettings
    if ($status -and $s) {
        Write-Prompt $s.BeforeText -BackgroundColor $s.BeforeBackgroundColor -ForegroundColor $s.BeforeForegroundColor

        if ($status.BehindBy -eq 0 -and $status.AheadBy -eq 0) {
            # We are aligned with remote
            $branchStatusSymbol          = $s.BranchIdenticalStatusToSymbol
            $branchStatusBackgroundColor = $s.BranchIdenticalStatusToBackgroundColor
            $branchStatusForegroundColor = $s.BranchIdenticalStatusToForegroundColor
        } elseif ($status.BehindBy -ge 1 -and $status.AheadBy -ge 1) {
            # We are both behind and ahead of remote
            $branchStatusSymbol          = $s.BranchBehindAndAheadStatusSymbol
            $branchStatusBackgroundColor = $s.BranchBehindAndAheadStatusBackgroundColor
            $branchStatusForegroundColor = $s.BranchBehindAndAheadStatusForegroundColor
        } elseif ($status.BehindBy -ge 1) {
            # We are behind remote
            $branchStatusSymbol          = $s.BranchBehindStatusSymbol
            $branchStatusBackgroundColor = $s.BranchBehindStatusBackgroundColor
            $branchStatusForegroundColor = $s.BranchBehindStatusForegroundColor
        } elseif ($status.AheadBy -ge 1) {
            # We are ahead of remote
            $branchStatusSymbol          = $s.BranchAheadStatusSymbol
            $branchStatusBackgroundColor = $s.BranchAheadStatusBackgroundColor
            $branchStatusForegroundColor = $s.BranchAheadStatusForegroundColor
        } else {
            # This condition should not be possible but defaulting the variables to be safe
            $branchStatusSymbol          = "?"
            $branchStatusBackgroundColor = $Host.UI.RawUI.BackgroundColor
            $branchStatusForegroundColor = $Host.UI.RawUI.ForegroundColor
        }

        Write-Prompt  (" {0}" -f $branchStatusSymbol) -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor

        Write-Prompt (Format-BranchName( " " + $status.Branch)) -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor



        if($s.EnableFileStatus -and $status.HasIndex) {
            Write-Prompt $s.BeforeIndexText -BackgroundColor $s.BeforeIndexBackgroundColor -ForegroundColor $s.BeforeIndexForegroundColor

            if($s.ShowStatusWhenZero -or $status.Index.Added) {
              Write-Prompt " $($cp + $status.Index.Added.Count)" -BackgroundColor $s.IndexBackgroundColor -ForegroundColor $s.IndexForegroundColor
            }
            if($s.ShowStatusWhenZero -or $status.Index.Modified) {
              Write-Prompt " $($cm + $status.Index.Modified.Count)" -BackgroundColor $s.IndexBackgroundColor -ForegroundColor $s.IndexForegroundColor
            }
            if($s.ShowStatusWhenZero -or $status.Index.Deleted) {
              Write-Prompt " $($cd + $status.Index.Deleted.Count)" -BackgroundColor $s.IndexBackgroundColor -ForegroundColor $s.IndexForegroundColor
            }

            if ($status.Index.Unmerged) {
                Write-Prompt " $($ce + $status.Index.Unmerged.Count)" -BackgroundColor $s.IndexBackgroundColor -ForegroundColor $s.IndexForegroundColor
            }

            if($status.HasWorking) {
                Write-Prompt $s.DelimText -BackgroundColor $s.DelimBackgroundColor -ForegroundColor $s.DelimForegroundColor
            }
        }

        if($s.EnableFileStatus -and $status.HasWorking) {
            if($s.ShowStatusWhenZero -or $status.Working.Added) {
              Write-Prompt " $($cp + $status.Working.Added.Count)" -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.WorkingForegroundColor
            }
            if($s.ShowStatusWhenZero -or $status.Working.Modified) {
              Write-Prompt " $($cm + $status.Working.Modified.Count)" -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.WorkingForegroundColor
            }
            if($s.ShowStatusWhenZero -or $status.Working.Deleted) {
              Write-Prompt " $($cd + $status.Working.Deleted.Count)" -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.WorkingForegroundColor
            }

            if ($status.Working.Unmerged) {
                Write-Prompt " $($ce + $status.Working.Unmerged.Count)" -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.WorkingForegroundColor
            }
        }

        if ($status.HasWorking) {
            # We have un-staged files in the working tree
            $localStatusSymbol          = $s.LocalWorkingStatusSymbol
            $localStatusBackgroundColor = $s.LocalWorkingStatusBackgroundColor
            $localStatusForegroundColor = $s.LocalWorkingStatusForegroundColor
        } elseif ($status.HasIndex) {
            # We have staged but uncommited files
            $localStatusSymbol          = $s.LocalStagedStatusSymbol
            $localStatusBackgroundColor = $s.LocalStagedStatusBackgroundColor
            $localStatusForegroundColor = $s.LocalStagedStatusForegroundColor
        } else {
            # No uncommited changes
            $localStatusSymbol          = $s.LocalDefaultStatusSymbol
            $localStatusBackgroundColor = $s.LocalDefaultStatusBackgroundColor
            $localStatusForegroundColor = $s.LocalDefaultStatusForegroundColor
        }

        if ($localStatusSymbol) {
            Write-Prompt (" {0}" -f $localStatusSymbol) -BackgroundColor $localStatusBackgroundColor -ForegroundColor $localStatusForegroundColor
        }

        Write-Prompt $s.AfterText -BackgroundColor $s.AfterBackgroundColor -ForegroundColor $s.AfterForegroundColor

        if ($WindowTitleSupported -and $s.EnableWindowTitle) {
            if( -not $Global:PreviousWindowTitle ) {
                $Global:PreviousWindowTitle = $Host.UI.RawUI.WindowTitle
            }
            $repoName = Split-Path -Leaf (Split-Path $status.GitDir)
            $prefix = if ($s.EnableWindowTitle -is [string]) { $s.EnableWindowTitle } else { '' }
            $Host.UI.RawUI.WindowTitle = "$script:adminHeader$prefix$repoName [$($status.Branch)]"
        }
    } elseif ( $Global:PreviousWindowTitle ) {
        $Host.UI.RawUI.WindowTitle = $Global:PreviousWindowTitle
    }
}

if(!(Test-Path Variable:Global:VcsPromptStatuses)) {
    $Global:VcsPromptStatuses = @()
}
$s = $global:GitPromptSettings

# Override some of the normal colors if the background color is set to the default DarkMagenta.
if ($Host.UI.RawUI.BackgroundColor -eq [ConsoleColor]::DarkMagenta) {
    $s.LocalDefaultStatusForegroundColor    = $s.LocalDefaultStatusForegroundBrightColor
    $s.LocalWorkingStatusForegroundColor    = $s.LocalWorkingStatusForegroundBrightColor

    $s.BeforeIndexForegroundColor           = $s.BeforeIndexForegroundBrightColor
    $s.IndexForegroundColor                 = $s.IndexForegroundBrightColor

    $s.WorkingForegroundColor               = $s.WorkingForegroundBrightColor
}

function Global:Write-VcsStatus { $Global:VcsPromptStatuses | foreach { & $_ } }

# Add scriptblock that will execute for Write-VcsStatus
$PoshGitVcsPrompt = {
    $Global:GitStatus = Get-GitStatus
    Write-GitStatus $GitStatus
}
$Global:VcsPromptStatuses += $PoshGitVcsPrompt
$ExecutionContext.SessionState.Module.OnRemove = { $Global:VcsPromptStatuses = $Global:VcsPromptStatuses | ? { $_ -ne $PoshGitVcsPrompt} }