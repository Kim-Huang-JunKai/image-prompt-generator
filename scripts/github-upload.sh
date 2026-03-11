#!/bin/bash

# GitHub Upload Script
# 用法：./scripts/github-upload.sh [repo_name] [description] [visibility]

set -e

REPO_NAME="${1:-}"
DESCRIPTION="${2:-}"
VISIBILITY="${3:-public}"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo_error() {
    echo -e "${RED}$1${NC}"
}

echo_success() {
    echo -e "${GREEN}$1${NC}"
}

echo_warning() {
    echo -e "${YELLOW}$1${NC}"
}

echo_info() {
    echo -e "${CYAN}$1${NC}"
}

# 1. 环境检查
echo_info "=== GitHub 上传器 ==="
echo_info ""
echo_info "步骤 1/5: 检查环境..."

if ! command -v gh &> /dev/null; then
    echo_error "错误：未找到 GitHub CLI (gh)"
    echo_warning "请先安装：https://cli.github.com/"
    echo ""
    echo "Windows 用户可以使用:"
    echo "  winget install GitHub.cli"
    echo "  或从 https://cli.github.com/ 下载安装"
    exit 1
fi

GH_VERSION=$(gh --version | head -n1)
echo_success "  [✓] GitHub CLI: $GH_VERSION"

if ! command -v git &> /dev/null; then
    echo_error "错误：未找到 git"
    exit 1
fi
echo_success "  [✓] Git 已安装"

# 2. 认证检查
echo_info ""
echo_info "步骤 2/5: 检查认证状态..."

if gh auth status &> /dev/null; then
    echo_success "  [✓] 已登录 GitHub"
else
    echo_warning "  [!] 未登录 GitHub"
    echo ""
    echo_info "正在启动登录流程..."
    echo ""
    echo "请选择登录方式:"
    echo "  1) 浏览器登录 (推荐)"
    echo "  2) 使用 Token 登录"
    read -p "请选择 [1/2]：" login_choice

    if [ "$login_choice" = "2" ]; then
        gh auth login --with-token
    else
        gh auth login
    fi

    if gh auth status &> /dev/null; then
        echo_success "  [✓] 登录成功"
    else
        echo_error "  [×] 登录失败"
        exit 1
    fi
fi

# 配置 git 使用 gh 认证
gh auth setup-git 2>/dev/null || true

# 3. 获取仓库信息
echo_info ""
echo_info "步骤 3/5: 配置仓库信息..."

if [ -z "$REPO_NAME" ]; then
    # 尝试从当前目录名推断
    DEFAULT_NAME=$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
    read -p "请输入仓库名称 [$DEFAULT_NAME]: " REPO_NAME
    REPO_NAME="${REPO_NAME:-$DEFAULT_NAME}"
fi

# 验证仓库名称
if ! [[ "$REPO_NAME" =~ ^[a-z0-9-]+$ ]]; then
    echo_error "错误：仓库名称只能包含小写字母、数字和连字符"
    exit 1
fi

if [ -z "$DESCRIPTION" ]; then
    read -p "请输入仓库描述 (可选): " DESCRIPTION
fi

if [ -z "$VISIBILITY" ]; then
    echo ""
    echo "选择可见性:"
    echo "  1) public  (公开) - 任何人都可以看到"
    echo "  2) private (私有) - 只有你和协作者可以看到"
    read -p "请选择 [1/2]：" choice
    if [ "$choice" = "2" ]; then
        VISIBILITY="private"
    else
        VISIBILITY="public"
    fi
fi

# 4. 确认配置
echo_info ""
echo_info "步骤 4/5: 确认配置..."
echo ""
echo "┌──────────────────────────────────────────────────────┐"
echo "│  仓库配置摘要                                         │"
echo "├──────────────────────────────────────────────────────┤"
echo "│  名称：$REPO_NAME"
if [ -n "$DESCRIPTION" ]; then
    printf "│  描述：%-50s│\n" "$DESCRIPTION"
else
    echo "│  描述：无"
fi
echo "│  可见性：$VISIBILITY"
echo "│  推送内容：当前目录 (根据 .gitignore 过滤)"
echo "└──────────────────────────────────────────────────────┘"
echo ""
read -p "确认创建仓库并推送代码？(y/n): " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo_warning "已取消操作"
    exit 0
fi

# 5. 执行创建和推送
echo_info ""
echo_info "步骤 5/5: 创建仓库并推送..."

# 检查是否是 git 仓库
if [ ! -d ".git" ]; then
    echo_info "  初始化 git 仓库..."
    git init
    git branch -M main
fi

# 检查是否有未提交的更改
if ! git diff --quiet; then
    echo_warning "  检测到未提交的更改，正在提交..."
    git add -A
    git commit -m "chore: initial commit before GitHub upload"
fi

# 创建并推送
echo_info "  正在创建 GitHub 仓库..."

if [ -n "$DESCRIPTION" ]; then
    gh repo create "$REPO_NAME" --"$VISIBILITY" --description="$DESCRIPTION" --source=. --push
else
    gh repo create "$REPO_NAME" --"$VISIBILITY" --source=. --push
fi

# 6. 完成
echo ""
echo_success "╔══════════════════════════════════════════════════════════╗"
echo_success "║                    上传完成！                            ║"
echo_success "╚══════════════════════════════════════════════════════════╝"
echo ""

# 获取用户名
USERNAME=$(gh api user --jq .login 2>/dev/null || echo "username")

echo_success "  仓库地址：https://github.com/$USERNAME/$REPO_NAME"
echo ""
echo_info "提示："
echo "  - 查看仓库：gh repo view"
echo "  - 打开网页：gh repo view --web"
echo ""
