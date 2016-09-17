$confirmXML = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:PowershellGUI"
        ResizeMode="NoResize"
        Title="Welcome" Height="125" Width="410">
    <Grid>
        <StackPanel HorizontalAlignment="Center" Margin="15,10,15,0">
            <TextBlock Text="This is the build menu script for Windows.  It is capable of building Windows and Android native components."
                       TextWrapping="Wrap" />
            <Button Name="_finishButton" Content="OK" HorizontalAlignment="Left" Width="50" Margin="0,10" />
        </StackPanel>
    </Grid>
</Window>
"@

$selectLibXML = @"
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:PowershellGUI"
        ResizeMode="NoResize"
        Title="Select Libraries to Build" Height="125" Width="300">
    <Grid>
        <StackPanel Margin="10,0">
            <StackPanel Orientation="Horizontal">
                <CheckBox Name="_cbForestCheckbox" IsChecked="True" VerticalAlignment="Center" />
                <Label Content="CBForest-Interop" />
            </StackPanel>
            <StackPanel Orientation="Horizontal">
                <CheckBox Name="_tokenizerCheckbox" IsChecked="True" VerticalAlignment="Center" />
                <Label Content="Tokenizer" />
            </StackPanel>
            <StackPanel Orientation="Horizontal">
                <Button Name="_finishButton" Content="OK" Width="100" />
                <Button Name="_cancelButton" Content="Cancel" Width="100" Margin="15,0" />
            </StackPanel>
        </StackPanel>
    </Grid>
</Window>
"@

$selectPlatformXML = @"
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:PowershellGUI"
        ResizeMode="NoResize"
        Title="Select the platforms to build for" Height="125" Width="300">
    <Grid>
        <StackPanel Margin="10,0">
            <StackPanel Orientation="Horizontal">
                <CheckBox Name="_windowsCheckbox" IsChecked="True" VerticalAlignment="Center" />
                <Label Content="Windows" />
            </StackPanel>
            <StackPanel Orientation="Horizontal">
                <CheckBox Name="_androidCheckbox" IsChecked="True" VerticalAlignment="Center" />
                <Label Content="Android" />
            </StackPanel>
            <StackPanel Orientation="Horizontal">
                <Button Name="_finishButton" Content="OK" Width="100" />
                <Button Name="_cancelButton" Content="Cancel" Width="100" Margin="15,0" />
            </StackPanel>
        </StackPanel>
    </Grid>
</Window>
"@

function Show-Window
{
    $script:continue = $False
    [xml]$xaml = $args[0]
    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
    $Window=[Windows.Markup.XamlReader]::Load( $reader )
    $xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Window.FindName($_.Name) -Scope Script}
    $WPF_finishButton.Add_Click({
        $script:continue = $True
        $Window.Close()
    })
    if ($WPF_cancelButton -ne $null) {
        $WPF_cancelButton.Add_Click({$Window.Close()})
    }

    $Window.ShowDialog() | out-null
    if (!$script:continue) {
        exit
    }
}

function Build-Android {
    # HACK: Android paths can easily get too long, so need to make them as short as possible.
    # The topmost possible build directory will be linked to C:\a (or whatever letter HOMEDRIVE is)
    # and removed afterwords
    $lib = $args[0]
    if($lib -eq "CBForest") {
        pushd src\StorageEngines\ForestDB\CBForest\
        cmd.exe /c mklink /J $env:HOMEDRIVE\a $pwd
        popd
        pushd $env:HOMEDRIVE\a\CSharp\NativeBuild\
        ndk-build -j8 -C jni
        cp -Recurse -Force libs/* ../prebuilt/
        Remove-Item -Recurse -Force libs
        popd
        $link = Get-Item $env:HOMEDRIVE\a\
        $link.Delete()
    } else {
        cmd.exe /c mklink /J $env:HOMEDRIVE\a $pwd
        pushd $env:HOMEDRIVE\a\vendor\sqlite3-unicodesn\
        ndk-build -j8 -C jni
        popd
        $link = Get-Item $env:HOMEDRIVE\a\
        $link.Delete()
    }
}

function Build-Windows {
    $lib = $args[0]
    echo $lib
    if($lib -eq "CBForest") {
        src\StorageEngines\ForestDB\CBForest\CSharp\NativeBuild\build-windows.bat
    } else {
        vendor\sqlite3-unicodesn\build-windows.bat
    }
}

function Build
{
    $lib=$args[0]
    $platform=$args[1]
    if ($platform -eq "Android") {
        Build-Android $lib
    } else {
        Build-Windows $lib
    }
}

[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
Show-Window $confirmXML
Show-Window $selectLibXML
$libList = New-Object System.Collections.ArrayList
if ($WPF_cbForestCheckbox.IsChecked) {
    $libList.Add("CBForest") > $null
}

if ($WPF_tokenizerCheckbox.IsChecked) {
    $libList.Add("Tokenizer") > $null
}

Show-Window $selectPlatformXML
$platformList = New-Object System.Collections.ArrayList
if ($WPF_windowsCheckbox.IsChecked) {
    $platformList.Add("Windows") > $null
}

if ($WPF_androidCheckbox.IsChecked) {
    $platformList.Add("Android") > $null
    Get-Command ndk-build 2>&1> $null
    if (!$?) {
        echo "ndk-build could not be found, make sure it is present in the system path"
        exit 1
    }
}

foreach ($platform in $platformList) {
    foreach ($lib in $libList) {
        Build $lib $platform
    }
}
