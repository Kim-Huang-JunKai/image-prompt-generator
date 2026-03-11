# GitHub 上传技能使用指南

## 快速开始

本仓库包含一个实用的 GitHub 上传技能，可以帮助你快速将代码上传到 GitHub。

## 使用方法

### 方式一：使用 Trae 技能（推荐）

在 Trae 中，只需说：

```
上传代码到 GitHub
```

技能会自动引导你完成：
1. 检查 GitHub CLI 是否安装
2. 检查登录状态
3. 输入仓库名称和描述
4. 选择可见性（公开/私有）
5. 自动创建并推送

### 方式二：使用脚本

**Windows 用户：**

```bash
# 进入项目目录
cd D:\code\ClaudeCode

# 运行上传脚本
./scripts/github-upload.bat

# 或者指定参数
./scripts/github-upload.bat image-prompt-generator "AI 生图提示词生成器" public
```

**Mac/Linux 用户：**

```bash
# 进入项目目录
cd /path/to/your/project

# 运行上传脚本
chmod +x scripts/github-upload.sh
./scripts/github-upload.sh

# 或者指定参数
./scripts/github-upload.sh image-prompt-generator "AI 生图提示词生成器" public
```

### 方式三：直接使用 gh 命令

如果你熟悉 GitHub CLI，可以直接使用：

```bash
# 登录（如果还未登录）
gh auth login

# 创建并推送
gh repo create <repo-name> --public --source=. --push
```

## 前置条件

### 1. 安装 GitHub CLI

**Windows：**
```bash
winget install GitHub.cli
# 或从 https://cli.github.com/ 下载
```

**macOS：**
```bash
brew install gh
```

**Linux：**
```bash
sudo apt install gh  # Debian/Ubuntu
sudo dnf install gh  # Fedora
```

### 2. 安装 Git

如果未安装 Git，请先安装：https://git-scm.com/

## 当前项目结构

```
D:\code\ClaudeCode\
├── .trae/
│   └── skills/
│       ├── image-prompt-generator/  ← 要上传的技能
│       │   ├── SKILL.md
│       │   └── styles/
│       │       ├── 3d-ecommerce-promotion.md
│       │       └── chibi-anime-product.md
│       └── github-uploader/         ← 上传工具技能
│           ├── SKILL.md
│           └── commands/
│               └── upload.md
├── scripts/
│   ├── github-upload.sh             ← Bash 脚本
│   └── github-upload.bat            ← Windows 脚本
├── .gitignore
└── README.md
```

## 上传内容说明

根据 `.gitignore` 配置，当前项目上传到 GitHub 时只包含：

- `.trae/skills/image-prompt-generator/` - AI 生图提示词生成器技能
- `.trae/skills/github-uploader/` - GitHub 上传技能
- `scripts/` - 上传脚本
- `README.md` - 项目说明
- `.gitignore` - Git 忽略配置

以下内容**不会**被上传：
- Python 缓存文件
- Node.js 模块
- IDE 配置文件
- 系统文件
- 其他 Trae 技能

## 常见问题

### Q: 仓库名称有什么要求？

A: 仓库名称只能包含：
- 小写字母 (a-z)
- 数字 (0-9)
- 连字符 (-)

例如：`image-prompt-generator`、`my-skill-2024`

### Q: 公开 (Public) 和私有 (Private) 有什么区别？

A:
- **Public**：任何人都可以看到，适合开源项目
- **Private**：只有你和被邀请的协作者可以看到

### Q: 如何查看已上传的仓库？

A:
```bash
# 在终端查看
gh repo view

# 在浏览器中打开
gh repo view --web
```

### Q: 上传失败了怎么办？

A: 常见原因和解决方案：

1. **未登录**：运行 `gh auth login` 重新登录
2. **仓库已存在**：更换仓库名称或删除 GitHub 上的旧仓库
3. **网络问题**：检查网络连接，或使用代理

### Q: 如何修改已上传的内容？

A:
```bash
# 修改代码后
git add .
git commit -m "更新说明"
git push
```

## 技能文件说明

### `.trae/skills/github-uploader/SKILL.md`

主技能文件，包含：
- 技能功能说明
- 交互式使用流程
- 命令参考
- 故障排除指南

### `.trae/skills/github-uploader/commands/upload.md`

命令详细定义，包含：
- 命令执行流程
- Bash 脚本实现
- PowerShell 实现
- 简化版本

### `scripts/github-upload.sh` / `github-upload.bat`

可独立运行的上传脚本，提供：
- 彩色输出
- 交互式引导
- 环境检查
- 错误处理

## 扩展建议

### 添加更多技能

在 `.trae/skills/` 目录添加新技能，然后修改 `.gitignore`：

```gitignore
.trae/skills/
!.trae/skills/image-prompt-generator/
!.trae/skills/github-uploader/
!.trae/skills/your-new-skill/  # 添加这行
```

### 自定义脚本

可以修改 `scripts/github-upload.sh` 来添加自定义功能，例如：
- 自动创建 Release
- 添加 License 文件
- 批量上传多个技能

## 相关链接

- [GitHub CLI 官方文档](https://cli.github.com/manual/)
- [Git 官方文档](https://git-scm.com/doc)
- [创建 GitHub 仓库](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository)
