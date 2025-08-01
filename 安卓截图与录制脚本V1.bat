@echo off
title Android ��Ļ���񹤾� by Sting
setlocal enabledelayedexpansion

:: ��ʼ������
set "adb_path=adb"
set "record_duration=10"
set "continuous_count=5"
set "continuous_interval=1"
set "show_adb_link=1"

:: �����Զ����ADB
where adb >nul 2>&1
if %errorlevel% equ 0 (
    set "adb_source=ϵͳ��������"
    set "show_adb_link=0"
    goto main_menu
)

:: ��ʾADB������ʾ�����ڵ�һ����Ҫʱ��ʾ��
if !show_adb_link! equ 1 (
    cls
    echo;
    echo ============================== ADB ������ʾ ==============================
    echo δ��ϵͳ·�����ҵ� adb.exe
    echo;
    echo �����û�а�װ ADB�����Դ����¹ٷ������������°�� SDK Platform-Tools��
    echo;
    echo   Windows: https://dl.google.com/android/repository/platform-tools-latest-windows.zip
    echo   Mac:     https://dl.google.com/android/repository/platform-tools-latest-darwin.zip
    echo   Linux:   https://dl.google.com/android/repository/platform-tools-latest-linux.zip
    echo;
    echo ����˵��:
    echo   1. ���ض�Ӧ����ϵͳ��ZIP�ļ�
    echo   2. ��ѹ�󣬻���platform-tools�ļ������ҵ�adb.exe
    echo   3. ʹ�ñ��ű�ʱ��ѡ����ļ����е�adb.exe
    echo;
    echo ������Ϣ: https://developer.android.google.cn/tools/releases/platform-tools?hl=zh-cn
    echo;
    echo ========================================================================
    echo;
    timeout /t 5 >nul
)

:: ֱ�ӽ����ļ������ѡ��ADB
goto browse_folder

:: �豸����ӳ��򣨴�����ѡ�
:check_device
echo;
echo ���ڼ���豸����...

:: ���ɿ����豸��ⷽ�� - ʹ�ô����ŵ�·��
"%adb_path%" devices >nul 2>&1
if %errorlevel% neq 0 (
    echo;
    echo ����ADB����δ����
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
    echo ��⵽����Ȩ�豸: !device_id!
    goto :eof
)

:device_error
echo;
echo ����δ�ҵ�����Ȩ�� Android �豸
echo ��ȷ����
echo   1. USB���������ã�����->������ѡ�
echo   2. �豸����Ȩ���鿴�豸������
echo   3. �豸ͨ��USB����
echo   4. ��װ��ȷ��USB��������
echo;
echo ���ӵ��豸�б�
"%adb_path%" devices
echo;

:device_retry
echo;
echo ��ѡ�������
echo   [R] ���¼���豸
echo   [C] ������������ADB
echo   [M] �������˵�
echo   [Q] �˳��ű�
echo;
set /p "retry_choice=��ѡ�� (R/C/M/Q): "

if /i "!retry_choice!"=="R" goto check_device
if /i "!retry_choice!"=="C" (
    echo;
    echo ������������ADB...
    "%adb_path%" kill-server
    timeout /t 2 >nul
    "%adb_path%" start-server
    timeout /t 2 >nul
    goto check_device
)
if /i "!retry_choice!"=="M" goto main_menu
if /i "!retry_choice!"=="Q" exit /b 1
goto device_retry

:: ����ļ���ѡ��ADB
:browse_folder
cls
echo;
echo ��ѡ�� adb.exe �����ļ���
set "folder="
for /f "delims=" %%I in ('powershell -Command "&{[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null; $f = New-Object System.Windows.Forms.FolderBrowserDialog; $f.Description = 'ѡ�� adb.exe �����ļ���'; if($f.ShowDialog() -eq 'OK'){ $f.SelectedPath }} "') do set "folder=%%I"

if not defined folder (
    echo;
    echo δѡ���ļ���
    timeout /t 2 >nul
    goto browse_folder
)

:: ���adb.exe�Ƿ����
if exist "!folder!\adb.exe" (
    set "adb_path=!folder!\adb.exe"
    set "adb_source=�ļ������"
    goto validate_adb
)

echo;
echo ����ѡ����ļ�����δ�ҵ� adb.exe
echo ѡ����ļ���: !folder!
echo;
echo ��ȷ�ϣ�
echo   1. ���ļ����Ƿ���� adb.exe
echo   2. �Ƿ���������ȷ��ƽ̨���߰�
echo   3. �Ƿ��ѹ�����ص�ZIP�ļ�
echo;
timeout /t 3 >nul
goto browse_folder

:: ��֤ADB��ִ����
:validate_adb
echo;
echo ��֤ ADB ��ִ����...
"%adb_path%" version >nul 2>&1
if %errorlevel% neq 0 (
    echo;
    echo ����adb.exe ��֤ʧ�� - "!adb_path!"
    echo ��ȷ��������Ч�� ADB ��ִ���ļ�
    echo;
    echo ����ԭ��
    echo   1. �ļ����𻵣����������أ�
    echo   2. �����ݵ�ADB�汾
    echo   3. ϵͳȨ������
    timeout /t 3 >nul
    goto browse_folder
)
set "show_adb_link=0"
goto main_menu

:: ���˵�
:main_menu
cls
echo;
echo ====== Android ��Ļ���񹤾� by Sting ======
echo;
echo ʹ�� ADB: !adb_path!
echo;
echo ��ѡ���ܣ�
echo 1. ���ν�ͼ
echo 2. ������ͼ�����ţ�
echo 3. ��Ļ¼��
echo 4. ����������ͼ����
echo 5. ����¼��ʱ��
echo 6. ����ѡ��ADB·��
echo 7. �˳�
echo;
set /p "choice=������ѡ�� (1-7): "

if "%choice%"=="1" goto single_screenshot
if "%choice%"=="2" goto continuous_screenshots
if "%choice%"=="3" goto record_video
if "%choice%"=="4" goto set_continuous_params
if "%choice%"=="5" goto set_record_duration
if "%choice%"=="6" goto browse_folder
if "%choice%"=="7" exit /b
goto main_menu

:: ����������ͼ����
:set_continuous_params
cls
echo;
echo ==== ����������ͼ���� ====
echo;
echo ��ǰ���ã�
echo   ��ͼ����: %continuous_count%
echo   ���ʱ��: %continuous_interval% ��
echo;
set /p "new_count=�����ͼ���� (Ĭ�� %continuous_count%): "
if not "!new_count!"=="" set "continuous_count=!new_count!"
set /p "new_interval=������ʱ��(��) (Ĭ�� %continuous_interval%): "
if not "!new_interval!"=="" set "continuous_interval=!new_interval!"
echo;
echo �����Ѹ��£�
echo   ��ͼ����: %continuous_count%
echo   ���ʱ��: %continuous_interval% ��
echo;
pause
goto main_menu

:: ����¼��ʱ�� - �Ƴ���180������
:set_record_duration
cls
echo;
echo ==== ������Ļ¼��ʱ�� ====
echo;
echo ��ǰ¼��ʱ��: %record_duration% ��
echo;
echo ��ʾ: ��������������ʱ��������ע�ⳤʱ��¼�ƻ�ռ�ô����洢�ռ�
echo;
set /p "new_duration=����¼��ʱ��(��) (Ĭ�� %record_duration%): "
if not "!new_duration!"=="" set "record_duration=!new_duration!"

echo;
echo ¼��ʱ��������Ϊ: %record_duration% ��
echo;
pause
goto main_menu

:: ����ʱ���
:generate_timestamp
:: ʹ��PowerShell��ȡʱ���
for /f "delims=" %%a in ('powershell -Command "Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'"') do set "timestamp=%%a"
goto :eof

:: ��֤������ - ������Ƿ�ѯ�ʴ��ļ��Ĳ���
:verify_capture
set "filename=%~1"
set "operation=%~2"
set "ask_open=%~3"

if exist "!filename!" (
    for %%F in ("!filename!") do set "filesize=%%~zF"
    if !filesize! gtr 0 (
        echo;
        echo !operation!�ɹ����浽: !filename!
        echo �ļ���С: !filesize! �ֽ�
        echo �ļ�·��: %cd%\!filename!
        
        :: ���Դ��ļ� - ʹ��ϵͳĬ�ϳ���
        if "!ask_open!"=="ASK" (
            echo;
            set /p "open=�Ƿ���ļ�? [Y/N]: "
            if /i "!open!"=="Y" (
                start "" "!filename!"
            )
        )
        goto :eof
    )
)

echo;
echo ����!operation!ʧ�ܣ��ļ���Ч
echo ����ԭ��:
echo   1. �豸���ӶϿ�
echo   2. ADB�汾������
echo   3. �豸Ȩ������
echo;
goto :eof

:: ���ν�ͼ - ʹ�ô����ŵ�ADB·��
:single_screenshot
call :check_device
call :generate_timestamp
set "filename=screenshot_%timestamp%.png"

echo;
echo ���ڲ�����Ļ��ͼ...
"%adb_path%" exec-out screencap -p > "!filename!"

if %errorlevel% neq 0 (
    echo;
    echo ���󣺽�ͼ����ִ��ʧ��
    echo ����ADB���Ӻ��豸״̬
    goto capture_error
)

call :verify_capture "!filename!" "���ν�ͼ" "ASK"
echo;
pause
goto main_menu

:capture_error
echo;
pause
goto main_menu

:: ������ͼ - ����ѯ���Ƿ��ÿ���ļ�
:continuous_screenshots
call :check_device
call :generate_timestamp
set "base_timestamp=!timestamp!"

echo;
echo ��ʼ������ͼ...
echo ��ͼ����: %continuous_count%
echo ���ʱ��: %continuous_interval% ��
echo;

for /l %%i in (1,1,%continuous_count%) do (
    set "filename=screenshot_%%i_!base_timestamp!.png"
    
    echo ���ڲ���� %%i/%continuous_count% �Ž�ͼ...
    "%adb_path%" exec-out screencap -p > "!filename!"
    
    if %errorlevel% neq 0 (
        echo;
        echo ���󣺽�ͼ����ִ��ʧ��
        echo ����ADB���Ӻ��豸״̬
        goto capture_error
    )
    
    :: ��֤�ļ�����ѯ���Ƿ��
    if exist "!filename!" (
        for %%F in ("!filename!") do set "filesize=%%~zF"
        if !filesize! gtr 0 (
            echo ��ͼ�ɹ�: !filename! ��С: !filesize! �ֽ�
        ) else (
            echo ���棺��ͼ�ļ�Ϊ�� - !filename!
        )
    ) else (
        echo ���󣺽�ͼ�ļ�δ���� - !filename!
    )
    
    if %%i lss %continuous_count% (
        echo �ȴ� %continuous_interval% ��...
        timeout /t %continuous_interval% >nul
    )
)

echo;
echo ������ͼ���!
echo;
echo ���н�ͼ�ѱ��浽��ǰĿ¼
echo;
pause
goto main_menu

:: ��Ļ¼�� - �޸���������
:record_video
call :check_device
call :generate_timestamp
set "filename=screenrecord_%timestamp%.mp4"

echo;
echo ��ʼ��Ļ¼��...
echo ¼��ʱ��: %record_duration% ��
echo;

echo ��ʾ: ���� Ctrl+C��������ܵ���¼��ʧ��
echo;

:: ֱ������¼���������ʹ�ú�̨������
echo ����¼��...
"%adb_path%" shell screenrecord --time-limit %record_duration% /sdcard/screenrecord_temp.mp4
if %errorlevel% neq 0 (
    echo;
    echo ����¼�ƹ����г��ִ���
    goto capture_error
)

:: �ȴ�¼�����
timeout /t 2 >nul

echo;
echo ���ڴ��豸����¼���ļ�...
"%adb_path%" pull /sdcard/screenrecord_temp.mp4 "!filename!" >nul
"%adb_path%" shell rm /sdcard/screenrecord_temp.mp4

:: ����ļ��Ƿ���Ч
if not exist "!filename!" (
    echo;
    echo ����¼���ļ�δ����
    goto capture_error
)

for %%F in ("!filename!") do set "filesize=%%~zF"
if !filesize! lss 1000 (
    echo;
    echo ����¼�Ƶ��ļ���С�쳣 (!filesize! �ֽ�)
    echo ����ԭ��: �豸¼��ʧ�ܻ�ADB�������
    goto capture_error
)

call :verify_capture "!filename!" "��Ļ¼��" "ASK"
echo;
pause
goto main_menu

:: ���ƽ�����
:draw_progress_bar
setlocal
set "percent=%~1"
set "label=%~2"
set "bar="
set /a "bars=percent/2"

for /l %%i in (1,1,50) do (
    if %%i leq !bars! (
        set "bar=!bar!��"
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