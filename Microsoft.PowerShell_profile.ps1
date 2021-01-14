Trap {"Error: $_"; Break;}

Import-Module posh-git
Import-Module PowerTab
Import-Module PowerLS
Import-Module PSColor
Import-Module PsIniFile
Import-Module PSReadLine
Import-Module PsIniFile

# Back to the last pwd
Remove-Item Alias:cd
function cd {
  if ($args[0] -eq '-') {
    $pwd=$OLDPWD;
  } else {
    $pwd=$args[0];
  }

  $tmp=pwd;

  if ($pwd) {
    Set-Location $pwd;
  }
  Set-Variable -Name OLDPWD -Value $tmp -Scope global;
}

# Create folder and cd into it.
function mdd {
  $d = md $args
  $s = pushd $d
  return $s
}

# Create File and Edited
function ts {
  $touch = New-Item $Args
  $subl = subl $Args
  return $subl
}

#Create directory and edit with sublime text 3
function mds {
  $dir = md $Args
  $subl = subl $dir
  return $subl
}

# Remove folder
function rmd {
  rm $args -Force
}

#Sublime Package Folder
function spf {
  cd "C:\Users\bilbo\AppData\Roaming\Sublime Text 3\Packages"
}

# Alias
[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding(850)
Remove-Item Alias:gcm -Force
function gcl { git clone $Args }
function gst { git status $Args }
function gtc { git clean $Args }
function gcm { git commit $Args }
function gta { git add $Args }
function gr { rails $Args }
function rs { rails s }
function grg { rails generate $Args }
function be { bundle exec $Args }
function bem { bundle exec middleman $Args }
Clear-Host

# Set up a Cmder prompt, adding the git prompt parts inside git repos
function global:prompt {

    $realLASTEXITCODE = $LASTEXITCODE
    $global:LASTEXITCODE = $realLASTEXITCODE
    $char = [char]0xe0b0
    $host.UI.RawUi.WindowTitle = [System.Environment]::MachineName
    $userLocation = $env:username + '@' + [System.Environment]::MachineName + " "
    $path = " "
    $pathbits = ([string]$pwd).split("\", [System.StringSplitOptions]::RemoveEmptyEntries)
    if($pathbits.length -eq 1) {
      $path = $pathbits[0] + "\"
    } else {
      $path = $pathbits[$pathbits.length - 1]
    }

    Write-Host("`n") -nonewline
    Write-Host("╭─") -nonewline -foregroundcolor Blue
    Write-Host([char]0x2592) -nonewline -backgroundcolor Blue -foregroundcolor DarkBlue
    Write-Host($userLocation) -nonewline -backgroundcolor Blue -foregroundcolor white
    Write-Host($char) -nonewline -backgroundcolor Yellow -foregroundcolor Blue
    Write-Host(" " + $path + " ") -nonewline -backgroundcolor Yellow -foregroundcolor Black
    Write-Host($char) -nonewline -backgroundcolor DarkBlue -foregroundcolor yellow
    Write-VcsStatus
    Write-Host($char) -nonewline -foregroundcolor DarkBlue
    Write-Host("`n╰─") -NoNewLine -ForegroundColor Blue
    Write-Host([char]0x25ba) -NoNewLine -ForegroundColor Blue
    return " "
}
Pop-Location

