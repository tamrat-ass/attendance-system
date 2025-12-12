$env:JAVA_HOME = "C:\Program Files\Microsoft\jdk-17.0.17.10-hotspot"
$env:ANDROID_HOME = "$env:USERPROFILE\Android"
$env:PATH += ";$env:JAVA_HOME\bin;$env:USERPROFILE\flutter\bin;$env:ANDROID_HOME\cmdline-tools\latest\bin;$env:ANDROID_HOME\platform-tools"

# Accept all licenses automatically
$licenses = @("y", "y", "y", "y", "y", "y", "y", "y", "y", "y")
$licenses | & flutter doctor --android-licenses