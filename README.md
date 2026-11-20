# Dotfiles

我的 macOS 开发环境配置：Ghostty、Zsh、Git、SSH、Zed，以及日常使用的 agent 规则、工程调查和写作 skills。
个人配置在这里维护；机器专属内容可以通过独立的本地扩展接入。

## 安装

先准备 Python 3、GNU Stow，以及配置中使用的 Oh My Zsh、fzf、zoxide 和 pyenv。
本仓库只管理配置，不代替软件安装、账号登录或凭据管理。

```bash
make check       # 检查语法、链接冲突和 diff，不写入文件
make install     # 更新受管链接
make test        # 临时 HOME 中验证安装、迁移、重复执行和卸载
make uninstall   # 移除受管链接，保留源码和用户数据
```

`Brewfile` 补充列出本仓库需要的 Stow、uv 和 Bun；基础软件由现有机器初始化流程准备。

## 配置来源

| 内容 | 源码 | 安装入口 |
| --- | --- | --- |
| 终端、Shell、Git、SSH、编辑器 | `ghostty/`、`zsh/`、`git/`、`ssh/`、`zed/` | 用户目录中的配置链接 |
| 通用 agent 规则 | `agents/AGENTS.md` | `~/.codex/AGENTS.md`、`~/.gemini/config/AGENTS.md` |
| 通用 skills | `agents/skills/` | `~/.agents/skills/<name>`、`~/.gemini/config/skills/<name>` |
| 链接归属与扩展选择 | 不入仓库 | `~/.local/share/dotfiles/` |
| agent 运行状态 | 不入仓库 | `~/.agents/state/` |

配置和 skills 链接源码；改动直接生效。新增或迁移文件后运行 `make install`。
`~/.agents` 保持真实目录，安装器保留用户自行添加的 skills 和运行状态。
不要单独 Stow 已由安装器管理的扩展和 agent 目录。

## 个人 skills

| 类别 | Skill | 何时使用 |
| --- | --- | --- |
| 工程调查 | [how](agents/skills/how/SKILL.md) | 当前怎样运行、改动该放在哪层 |
| 工程调查 | [why](agents/skills/why/SKILL.md) | 当时为什么这样做、历史约束是否有记录 |
| 工程调查 | [blast-radius](agents/skills/blast-radius/SKILL.md) | 某个改动会影响哪些消费者、关键前提是否成立 |
| 缺陷修复 | [tdd](agents/skills/tdd/SKILL.md) | 用 `$tdd` 调用，先复现失败，再用同一测试验证修复（[上游版本](https://github.com/cursor/plugins/blob/35a90942a7f02e1ebbc2443643179815f2147954/pstack/skills/tdd/SKILL.md)） |
| 专项核验 | [benchmark-checklist](agents/skills/benchmark-checklist/SKILL.md) | 判断性能比较是否成立，不自动启动压测 |
| 文稿编辑 | [technical-writing](agents/skills/technical-writing/SKILL.md) | 组织技术指南、README、设计说明和 PR/MR 内容 |
| 文稿编辑 | [humanizer](agents/skills/humanizer/SKILL.md) | 保留英文版润色规则，长示例按需读取 |
| 任务衔接 | [work-context](agents/skills/work-context/SKILL.md) | 恢复某项工作、保存检查点与决策依据 |
| 任务复盘 | [skill-retrospective](agents/skills/skill-retrospective/SKILL.md) | 把已发生的问题变成最小的技能或检查改进 |
| 凭据操作 | [op-vault](agents/skills/op-vault/SKILL.md) | 定位 1Password 条目、注入凭据并验证条目修改 |

分类只用于查找，安装目录保持扁平。通用协作偏好维护在 `agents/AGENTS.md`，
项目专属的启动、复现和验收流程放在对应项目；插件提供的 skills 由插件维护。

工程调查、写作和复盘技能参考 pstack 的局部方法，来源固定到各技能正文中的提交，许可随目录保留。

## 本地扩展

SSH 和 Zsh 支持以下可选配置文件：

```text
~/.ssh/config.local
~/.config/zsh/local.zsh
```

需要统一管理扩展时，在独立源码目录提供 `deployment.json`。例如：

```json
{
  "files": {
    ".ssh/config.local": "ssh/config",
    ".config/zsh/local.zsh": "zsh/local.zsh"
  },
  "skills": "agents/.agents/skills",
  "instructions": "codex/LOCAL.md"
}
```

只填写实际需要的字段。路径相对于扩展源码目录；扩展不能覆盖个人配置或使用同名 skill。
SSH 本地入口在 `Host *` 之前读取，供特定主机设置优先值。交互 shell 的本地入口为 `.config/zsh/local.zsh`，所有 zsh 的环境入口为
`.config/zsh/local.zshenv`；后者可读取已有会话环境，避免在 shell 启动时触发交互认证。

```bash
python3 scripts/deploy.py --extra-source /absolute/path/to/local-config install
make check
make install
```

安装成功后，本机记住扩展路径。后续 `make check` 和 `make install` 会继续包含它；
扩展目录丢失时停止并报错，不静默删除已安装内容。
启用扩展指令后，安装器将个人规则与扩展指令合并到本机生成文件，再链接到 Codex 和 Antigravity 入口。
修改任一指令源后重新安装，不直接编辑生成文件。

移除扩展并保留个人配置：

```bash
python3 scripts/deploy.py --without-extra install
```
