@echo off
chcp 65001 >nul 2>&1

REM GitHub Upload Script for Windows
REM 用法：github-upload.bat [repo_name] [description] [visibility]

setlocal enabledelayedexpansion

set "REPO_NAME=%~1"
set "DESCRIPTION=%~2"
set "VISIBILITY=%~3"

REM 颜色定义 (Windows 10+)
for /F %%a in 'echo prompt $E ^| cmd') do set "ESC=%%a"
set "RED=%ESC%[31m"
set "GREEN=%ESC%[32m"
set "YELLOW=%ESC%[33m"
set "CYAN=%ESC%[36m"
set "NC=%ESC%[0m"

echo %CYAN%=== GitHub 上传器 ===%NC%
echo.

REM 1. 环境检查
echo %CYAN%步骤 1/5: 检查环境...%NC%

where gh >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo %RED%错误：未找到 GitHub CLI (gh)%NC%
    echo %YELLOW%请先安装：https://cli.github.com/%NC%
    echo.
    echo Windows 用户可以使用:
    echo   winget install GitHub.cli
    echo   或从 https://cli.github.com/ 下载安装
    pause
    exit /b 1
)

for /f "delims=" %%i in ('gh --version') do (
    echo %GREEN%  [✓] GitHub CLI: %%i%NC%
    goto :gh_done
)
:gh_done

where git >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo %RED%错误：未找到 git%NC%
    pause
    exit /b 1
)
echo %GREEN%  [✓] Git 已安装%NC%

REM 2. 认证检查
echo.
echo %CYAN%步骤 2/5: 检查认证状态...%NC%

gh auth status >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo %GREEN%  [✓] 已登录 GitHub%NC%
) else (
    echo %YELLOW%  [!] 未登录 GitHub%NC%
    echo.
    echo %CYAN%正在启动登录流程...%NC%
    echo.
    echo 请选择登录方式:
    echo   1) 浏览器登录 (推荐)
    echo   2) 使用 Token 登录
    set /p login_choice="请选择 [1/2]: "

    if "%login_choice%"=="2" (
        gh auth login --with-token
    ) else (
        gh auth login
    )

    gh auth status >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        echo %RED%  [×] 登录失败%NC%
        pause
        exit /b 1
    )
    echo %GREEN%  [✓] 登录成功%NC%
)

REM 配置 git 使用 gh 认证
gh auth setup-git >nul 2>&1

REM 3. 获取仓库信息
echo.
echo %CYAN%步骤 3/5: 配置仓库信息...%NC%

if "%REPO_NAME%"=="" (
    for %%I in (".") do set "DEFAULT_NAME=%%~nxI"
    set /p "REPO_NAME=请输入仓库名称 [%DEFAULT_NAME%]: "
    if "!REPO_NAME!"=="" set "REPO_NAME=%DEFAULT_NAME%"
)

if "%DESCRIPTION%"=="" (
    set /p "DESCRIPTION=请输入仓库描述 (可选): "
)

if "%VISIBILITY%"=="" (
    echo.
    echo 选择可见性:
    echo   1) public  (公开) - 任何人都可以看到
    echo   2) private (私有) - 只有你和协作者可以看到
    set /p "choice=请选择 [1/2]: "
    if "!choice!"=="2" (
        set "VISIBILITY=private"
    ) else (
        set "VISIBILITY=public"
    )
)

REM 4. 确认配置
echo.
echo %CYAN%步骤 4/5: 确认配置...%NC%
echo.
echo +------------------------------------------------------+
echo !  仓库配置摘要                                         !
echo +------------------------------------------------------+
echo !  名称：%REPO_NAME%
if not "%DESCRIPTION%"=="" (
    echo !  描述：%DESCRIPTION%
) else (
    echo !  描述：无
)
echo !  可见性：%VISIBILITY%
echo !  推送内容：当前目录 (根据 .gitignore 过滤)
echo +------------------------------------------------------+
echo.
set /p "confirm=确认创建仓库并推送代码？(y/n): "

if /i not "%confirm%"=="y" (
    echo %YELLOW%已取消操作%NC%
    pause
    exit /b 0
)

REM 5. 执行创建和推送
echo.
echo %CYAN%步骤 5/5: 创建仓库并推送...%NC%

REM 检查是否是 git 仓库
if not exist ".git" (
    echo %CYAN%  初始化 git 仓库...%NC%
    git init
    git branch -M main
)

REM 检查是否有未提交的更改
git diff --quiet
if %ERRORLEVEL% neq 0 (
    echo %YELLOW%  检测到未提交的更改，正在提交...%NC%
    git add -A
    git commit -m "chore: initial commit before GitHub upload"
)

REM 创建并推送
echo %CYAN%  正在创建 GitHub 仓库...%NC%

if not "%DESCRIPTION%"=="" (
    gh repo create "%REPO_NAME%" --%VISIBILITY% --description="%DESCRIPTION%" --source=. --push
) else (
    gh repo create "%REPO_NAME%" --%VISIBILITY% --source=. --push
)

REM 6. 完成
echo.
echo %GREEN%+======================================================+%NC%
echo %GREEN%!                    上传完成！                            !%NC%
echo %GREEN%+======================================================+%NC%
echo.

REM 获取用户名
for /f "delims=" %%i in ('gh api user --jq .login 2^>nul') do set "USERNAME=%%i"
if "%USERNAME%"=="" set "USERNAME=username"

echo %GREEN%  仓库地址：https://github.com/%USERNAME%/%REPO_NAME%%NC%
echo.
echo %CYAN%提示：%NC%
echo   - 查看仓库：gh repo view
echo   - 打开网页：gh repo view --web
echo.

pause
