@echo off
title Android 屏幕捕获工具 by Sting
setlocal enabledelayedexpansion

:: 初始化变量
set "adb_path=adb"
set "record_duration=10"
set "continuous_count=5"
set "continuous_interval=1"
set "show_adb_link=1"

:: 尝试自动检测ADB
where adb >nul 2>&1
if %errorlevel% equ 0 (
    set "adb_source=系统环境变量"
    set "show_adb_link=0"
    goto main_menu
)

:: 显示ADB下载提示（仅在第一次需要时显示）
if !show_adb_link! equ 1 (
    cls
    echo;
    echo ============================== ADB 工具提示 ==============================
    echo 未在系统路径中找到 adb.exe
    echo;
    echo 如果您没有安装 ADB，可以从以下官方链接下载最新版的 SDK Platform-Tools：
    echo;
    echo   Windows: https://dl.google.com/android/repository/platform-tools-latest-windows.zip
    echo   Mac:     https://dl.google.com/android/repository/platform-tools-latest-darwin.zip
    echo   Linux:   https://dl.google.com/android/repository/platform-tools-latest-linux.zip
    echo;
    echo 下载说明:
    echo   1. 下载对应操作系统的ZIP文件
    echo   2. 解压后，会在platform-tools文件夹中找到adb.exe
    echo   3. 使用本脚本时，选择此文件夹中的adb.exe
    echo;
    echo 更多信息: https://developer.android.google.cn/tools/releases/platform-tools?hl=zh-cn
    echo;
    echo ========================================================================
    echo;
    timeout /t 5 >nul
)

:: 直接进入文件夹浏览选择ADB
goto browse_folder

:: 设备检测子程序（带重试选项）
:check_device
echo;
echo 正在检查设备连接...

:: 更可靠的设备检测方法 - 使用带引号的路径
"%adb_path%" devices >nul 2>&1
if %errorlevel% neq 0 (
    echo;
    echo 错误：ADB服务未运行
    goto device_error
)

set "device_found=0"
for /f "skip=1 tokens=1,2" %%a in ('"%adb_path%" devices') do (
    if "%%b"=="device" (
        set "device_found=1"
        set "device_id=%%a"
    )
)

if !device_found! equ 1 (
    echo 检测到已授权设备: !device_id!
    goto :eof
)

:device_error
echo;
echo 错误：未找到已授权的 Android 设备
echo 请确保：
echo   1. USB调试已启用（设置->开发者选项）
echo   2. 设备已授权（查看设备弹窗）
echo   3. 设备通过USB连接
echo   4. 安装正确的USB驱动程序
echo;
echo 连接的设备列表：
"%adb_path%" devices
echo;

:device_retry
echo;
echo 请选择操作：
echo   [R] 重新检测设备
echo   [C] 尝试重新连接ADB
echo   [M] 返回主菜单
echo   [Q] 退出脚本
echo;
set /p "retry_choice=请选择 (R/C/M/Q): "

if /i "!retry_choice!"=="R" goto check_device
if /i "!retry_choice!"=="C" (
    echo;
    echo 尝试重新连接ADB...
    "%adb_path%" kill-server
    timeout /t 2 >nul
    "%adb_path%" start-server
    timeout /t 2 >nul
    goto check_device
)
if /i "!retry_choice!"=="M" goto main_menu
if /i "!retry_choice!"=="Q" exit /b 1
goto device_retry

:: 浏览文件夹选择ADB
:browse_folder
cls
echo;
echo 请选择 adb.exe 所在文件夹
set "folder="
for /f "delims=" %%I in ('powershell -Command "&{[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null; $f = New-Object System.Windows.Forms.FolderBrowserDialog; $f.Description = '选择 adb.exe 所在文件夹'; if($f.ShowDialog() -eq 'OK'){ $f.SelectedPath }} "') do set "folder=%%I"

if not defined folder (
    echo;
    echo 未选择文件夹
    timeout /t 2 >nul
    goto browse_folder
)

:: 检查adb.exe是否存在
if exist "!folder!\adb.exe" (
    set "adb_path=!folder!\adb.exe"
    set "adb_source=文件夹浏览"
    goto validate_adb
)

echo;
echo 错误：选择的文件夹中未找到 adb.exe
echo 选择的文件夹: !folder!
echo;
echo 请确认：
echo   1. 该文件夹是否包含 adb.exe
echo   2. 是否下载了正确的平台工具包
echo   3. 是否解压了下载的ZIP文件
echo;
timeout /t 3 >nul
goto browse_folder

:: 验证ADB可执行性
:validate_adb
echo;
echo 验证 ADB 可执行性...
"%adb_path%" version >nul 2>&1
if %errorlevel% neq 0 (
    echo;
    echo 错误：adb.exe 验证失败 - "!adb_path!"
    echo 请确保这是有效的 ADB 可执行文件
    echo;
    echo 常见原因：
    echo   1. 文件已损坏（请重新下载）
    echo   2. 不兼容的ADB版本
    echo   3. 系统权限问题
    timeout /t 3 >nul
    goto browse_folder
)
set "show_adb_link=0"
goto main_menu

:: 主菜单
:main_menu
cls
echo;
echo ====== Android 屏幕捕获工具 by Sting ======
echo;
echo 使用 ADB: !adb_path!
echo;
echo 请选择功能：
echo 1. 单次截图
echo 2. 连续截图（多张）
echo 3. 屏幕录制
echo 4. 设置连续截图参数
echo 5. 设置录制时长
echo 6. 重新选择ADB路径
echo 7. 退出
echo;
set /p "choice=请输入选项 (1-7): "

if "%choice%"=="1" goto single_screenshot
if "%choice%"=="2" goto continuous_screenshots
if "%choice%"=="3" goto record_video
if "%choice%"=="4" goto set_continuous_params
if "%choice%"=="5" goto set_record_duration
if "%choice%"=="6" goto browse_folder
if "%choice%"=="7" exit /b
goto main_menu

:: 设置连续截图参数
:set_continuous_params
cls
echo;
echo ==== 设置连续截图参数 ====
echo;
echo 当前设置：
echo   截图张数: %continuous_count%
echo   间隔时间: %continuous_interval% 秒
echo;
set /p "new_count=输入截图张数 (默认 %continuous_count%): "
if not "!new_count!"=="" set "continuous_count=!new_count!"
set /p "new_interval=输入间隔时间(极) (默认 %continuous_interval%): "
if not "!new_interval!"=="" set "continuous_interval=!new_interval!"
echo;
echo 参数已更新：
echo   截图张数: %continuous_count%
echo   间隔时间: %continuous_interval% 秒
echo;
pause
goto main_menu

:: 设置录制时长 - 移除了180秒限制
:set_record_duration
cls
echo;
echo ==== 设置屏幕录制时长 ====
echo;
echo 当前录制时长: %record_duration% 秒
echo;
echo 提示: 您可以设置任意时长，但请注意长时间录制会占用大量存储空间
echo;
set /p "new_duration=输入录制时长(秒) (默认 %record_duration%): "
if not "!new_duration!"=="" set "record_duration=!new_duration!"

echo;
echo 录制时长已设置为: %record_duration% 秒
echo;
pause
goto main_menu

:: 生成时间戳
:generate_timestamp
:: 使用PowerShell获取时间戳
for /f "delims=" %%a in ('powershell -Command "Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'"') do set "timestamp=%%a"
goto :eof

:: 验证捕获结果 - 添加了是否询问打开文件的参数
:verify_capture
set "filename=%~1"
set "operation=%~2"
set "ask_open=%~3"

if exist "!filename!" (
    for %%F in ("!filename!") do set "filesize=%%~zF"
    if !filesize! gtr 0 (
        echo;
        echo !operation!成功保存到: !filename!
        echo 文件大小: !filesize! 字节
        echo 文件路径: %cd%\!filename!
        
        :: 尝试打开文件 - 使用系统默认程序
        if "!ask_open!"=="ASK" (
            echo;
            set /p "open=是否打开文件? [Y/N]: "
            if /i "!open!"=="Y" (
                start "" "!filename!"
            )
        )
        goto :eof
    )
)

echo;
echo 错误：!operation!失败，文件无效
echo 可能原因:
echo   1. 设备连接断开
echo   2. ADB版本不兼容
echo   3. 设备权限问题
echo;
goto :eof

:: 单次截图 - 使用带引号的ADB路径
:single_screenshot
call :check_device
call :generate_timestamp
set "filename=screenshot_%timestamp%.png"

echo;
echo 正在捕获屏幕截图...
"%adb_path%" exec-out screencap -p > "!filename!"

if %errorlevel% neq 0 (
    echo;
    echo 错误：截图命令执行失败
    echo 请检查ADB连接和设备状态
    goto capture_error
)

call :verify_capture "!filename!" "单次截图" "ASK"
echo;
pause
goto main_menu

:capture_error
echo;
pause
goto main_menu

:: 连续截图 - 不再询问是否打开每个文件
:continuous_screenshots
call :check_device
call :generate_timestamp
set "base_timestamp=!timestamp!"

echo;
echo 开始连续截图...
echo 截图数量: %continuous_count%
echo 间隔时间: %continuous_interval% 秒
echo;

for /l %%i in (1,1,%continuous_count%) do (
    set "filename=screenshot_%%i_!base_timestamp!.png"
    
    echo 正在捕获第 %%i/%continuous_count% 张截图...
    "%adb_path%" exec-out screencap -p > "!filename!"
    
    if %errorlevel% neq 0 (
        echo;
        echo 错误：截图命令执行失败
        echo 请检查ADB连接和设备状态
        goto capture_error
    )
    
    :: 验证文件但不询问是否打开
    if exist "!filename!" (
        for %%F in ("!filename!") do set "filesize=%%~zF"
        if !filesize! gtr 0 (
            echo 截图成功: !filename! 大小: !filesize! 字节
        ) else (
            echo 警告：截图文件为空 - !filename!
        )
    ) else (
        echo 错误：截图文件未创建 - !filename!
    )
    
    if %%i lss %continuous_count% (
        echo 等待 %continuous_interval% 秒...
        timeout /t %continuous_interval% >nul
    )
)

echo;
echo 连续截图完成!
echo;
echo 所有截图已保存到当前目录
echo;
pause
goto main_menu

:: 屏幕录制 - 修复闪退问题
:record_video
call :check_device
call :generate_timestamp
set "filename=screenrecord_%timestamp%.mp4"

echo;
echo 开始屏幕录制...
echo 录制时长: %record_duration% 秒
echo;

echo 提示: 请勿按 Ctrl+C，否则可能导致录制失败
echo;

:: 直接运行录制命令（不再使用后台启动）
echo 正在录制...
"%adb_path%" shell screenrecord --time-limit %record_duration% /sdcard/screenrecord_temp.mp4
if %errorlevel% neq 0 (
    echo;
    echo 错误：录制过程中出现错误
    goto capture_error
)

:: 等待录制完成
timeout /t 2 >nul

echo;
echo 正在从设备下载录制文件...
"%adb_path%" pull /sdcard/screenrecord_temp.mp4 "!filename!" >nul
"%adb_path%" shell rm /sdcard/screenrecord_temp.mp4

:: 检查文件是否有效
if not exist "!filename!" (
    echo;
    echo 错误：录制文件未创建
    goto capture_error
)

for %%F in ("!filename!") do set "filesize=%%~zF"
if !filesize! lss 1000 (
    echo;
    echo 错误：录制的文件大小异常 (!filesize! 字节)
    echo 可能原因: 设备录制失败或ADB传输错误
    goto capture_error
)

call :verify_capture "!filename!" "屏幕录制" "ASK"
echo;
pause
goto main_menu

:: 绘制进度条
:draw_progress_bar
setlocal
set "percent=%~1"
set "label=%~2"
set "bar="
set /a "bars=percent/2"

for /l %%i in (1,1,50) do (
    if %%i leq !bars! (
        set "bar=!bar!■"
    ) else (
        set "bar=!bar! "
    )
)

set /a "spaces=100-percent"
set "percent_str=!percent!%%"
if !percent! lss 10 set "percent_str=  !percent!%%"
if !percent! lss 100 if !percent! geq 10 set "percent_str= !percent!%%"

echo;
echo !label!: [!bar!] !percent_str!
endlocal
goto :eof