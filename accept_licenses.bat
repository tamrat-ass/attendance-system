@echo off
set JAVA_HOME=C:\Program Files\Microsoft\jdk-17.0.17.10-hotspot
set ANDROID_HOME=%USERPROFILE%\Android
set PATH=%PATH%;%JAVA_HOME%\bin;%USERPROFILE%\flutter\bin;%ANDROID_HOME%\cmdline-tools\latest\bin;%ANDROID_HOME%\platform-tools

echo y | flutter doctor --android-licenses
pause