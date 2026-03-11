# GitHub 上传命令

## 命令定义

### 主要命令：上传到 GitHub

**触发词：**
- 上传代码到 GitHub
- 发布到 GitHub
- 创建 GitHub 仓库
- 推送到 GitHub

**命令执行流程：**

```markdown
1. 环境检查
   ├── 检查 gh 是否安装
   ├── 检查 git 是否安装
   └── 检查当前目录是否为 git 仓库

2. 认证检查
   ├── gh auth status
   ├── 已登录 → 继续
   └── 未登录 → 引导登录

3. 仓库配置
   ├── 输入仓库名称
   ├── 输入仓库描述（可选）
   └── 选择可见性（public/private）

4. 确认配置
   └── 显示配置摘要，用户确认

5. 执行创建
   ├── git init (如果需要)
   ├── gh repo create
   └── git push

6. 完成反馈
   └── 显示仓库 URL
```

---

## 命令实现脚本

### 完整上传脚本

```bash
#!/bin/bash

# GitHub 上传脚本
# 用法：./github-upload.sh [repo_name] [description] [visibility]

REPO_NAME="${1:-}"
DESCRIPTION="${2:-}"
VISIBILITY="${3:-public}"

# 1. 环境检查
echo "检查环境..."

if ! command -v gh &> /dev/null; then
    echo "错误：未找到 GitHub CLI (gh)"
    echo "请先安装：https://cli.github.com/"
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo "错误：未找到 git"
    exit 1
fi

# 2. 认证检查
echo "检查认证状态..."
if ! gh auth status &> /dev/null; then
    echo "未登录 GitHub，请运行：gh auth login"
    gh auth login
fi

# 3. 获取仓库信息（如果未提供）
if [ -z "$REPO_NAME" ]; then
    read -p "请输入仓库名称：" REPO_NAME
fi

if [ -z "$DESCRIPTION" ]; then
    read -p "请输入仓库描述（可选）：" DESCRIPTION
fi

if [ -z "$VISIBILITY" ]; then
    echo "选择可见性："
    echo "1) public (公开)"
    echo "2) private (私有)"
    read -p "请选择 [1/2]：" choice
    if [ "$choice" = "2" ]; then
        VISIBILITY="private"
    else
        VISIBILITY="public"
    fi
fi

# 4. 确认配置
echo ""
echo "配置摘要："
echo "  仓库名称：$REPO_NAME"
echo "  描述：${DESCRIPTION:-无}"
echo "  可见性：$VISIBILITY"
echo ""
read -p "确认创建？(y/n)：" confirm
if [ "$confirm" != "y" ]; then
    echo "已取消"
    exit 0
fi

# 5. 创建仓库并推送
echo "正在创建仓库..."

if [ -n "$DESCRIPTION" ]; then
    gh repo create "$REPO_NAME" --$VISIBILITY --description="$DESCRIPTION" --source=. --push
else
    gh repo create "$REPO_NAME" --$VISIBILITY --source=. --push
fi

# 6. 完成
echo ""
echo "完成！"
echo "仓库地址：https://github.com/$(gh api user | jq -r .login)/$REPO_NAME"
```

---

## Windows PowerShell 版本

```powershell
# GitHub-Upload.ps1

param(
    [string]$RepoName = "",
    [string]$Description = "",
    [string]$Visibility = "public"
)

# 1. 环境检查
Write-Host "检查环境..." -ForegroundColor Cyan

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "错误：未找到 GitHub CLI (gh)" -ForegroundColor Red
    Write-Host "请先安装：https://cli.github.com/" -ForegroundColor Yellow
    exit 1
}

# 2. 认证检查
Write-Host "检查认证状态..." -ForegroundColor Cyan
$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "未登录 GitHub，正在引导登录..." -ForegroundColor Yellow
    gh auth login
}

# 3. 获取仓库信息
if ([string]::IsNullOrEmpty($RepoName)) {
    $RepoName = Read-Host "请输入仓库名称"
}

if ([string]::IsNullOrEmpty($Description)) {
    $Description = Read-Host "请输入仓库描述（可选）"
}

if ([string]::IsNullOrEmpty($Visibility)) {
    Write-Host "选择可见性：" -ForegroundColor Cyan
    Write-Host "1) public (公开)"
    Write-Host "2) private (私有)"
    $choice = Read-Host "请选择 [1/2]"
    $Visibility = if ($choice -eq "2") { "private" } else { "public" }
}

# 4. 确认配置
Write-Host ""
Write-Host "配置摘要：" -ForegroundColor Green
Write-Host "  仓库名称：$RepoName"
Write-Host "  描述：$Description"
Write-Host "  可见性：$Visibility"
Write-Host ""
$confirm = Read-Host "确认创建？(y/n)"
if ($confirm -ne "y") {
    Write-Host "已取消" -ForegroundColor Yellow
    exit 0
}

# 5. 创建仓库并推送
Write-Host "正在创建仓库..." -ForegroundColor Cyan

if ([string]::IsNullOrEmpty($Description)) {
    gh repo create $RepoName --$Visibility --source=. --push
} else {
    gh repo create $RepoName --$Visibility --description=$Description --source=. --push
}

# 6. 完成
Write-Host ""
Write-Host "完成！" -ForegroundColor Green
$user = gh api user | ConvertFrom-Json
Write-Host "仓库地址：https://github.com/$($user.login)/$RepoName" -ForegroundColor Green
```

---

## 简化版本（推荐用于技能实现）

### 单行命令

对于简单场景，可以使用单行命令：

```bash
# 交互模式（gh 会自动提示输入）
gh repo create --public --source=. --push

# 或指定名称
gh repo create my-repo --public --description="My Project" --source=. --push
```

### 认证设置

```bash
# 一键登录（使用浏览器）
gh auth login

# 设置 git 使用 gh 认证
gh auth setup-git
```

---

## 技能实现建议

### 推荐实现方式

由于 gh CLI 已经提供了完善的交互界面，技能可以实现为：

1. **检查阶段**：验证 gh 和 git 是否安装
2. **认证阶段**：检查登录状态，未登录则引导
3. **执行阶段**：调用 `gh repo create` 命令

### 示例实现

```python
# 伪代码示例
def upload_to_github(repo_name=None, description=None, visibility="public"):
    # 检查环境
    if not check_gh_installed():
        return "请先安装 GitHub CLI"

    # 检查认证
    if not check_gh_auth():
        run_command("gh auth login")

    # 构建命令
    cmd = f"gh repo create {repo_name} --{visibility}"
    if description:
        cmd += f' --description="{description}"'
    cmd += " --source=. --push"

    # 执行
    result = run_command(cmd)
    return f"上传完成！{result}"
```
