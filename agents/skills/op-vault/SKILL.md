---
name: op-vault
description: 使用 1Password CLI 定位条目、向命令注入凭据，以及创建、更新和整理条目；用于明确的 1Password 操作或任务所需的凭据读取，不自动配置认证或轮换上游密钥。
---

# 1Password 条目与凭据注入

沿用本机已有的 `op` 和认证方式。先查找与任务匹配的条目，明确账号、vault、item 和用途；找不到或有歧义时再问，不猜凭据，不默认使用名为 Work 或 Dev 的库。

## 认证与定位

用 `command -v op`、`op --version` 和相关子命令的 `--help` 核对本机能力。缺 CLI 时说明依赖；桌面集成需要 1Password 已登录并启用 CLI 集成。认证失败时区分未解锁、授权拒绝和权限不足，不自动切换身份绕过错误。

保留调用方明确指定的账号和认证环境。已有 service account 时，以目标 vault 的实际访问验证权限，不能用桌面身份的成功证明 service account 可用。不要为完成普通条目操作自动创建 service account、扩大权限，或把 token 导出到全局登录环境。

已知 vault 时直接限定查询；未知时仅列出必要的 vault 元数据。列表输出只保留候选标题、ID、vault，原始 JSON 可能带账号等信息；元数据本身也不默认适合公开。

```bash
set -o pipefail
op item list --vault '<vault>' --format json | python3 -c 'import json,sys; print([(i.get("title"), i.get("id"), i.get("vault")) for i in json.load(sys.stdin)])'
```

定位后优先使用 item ID，并继续显式指定 vault；多账号时同时限定账号。检查字段只输出 ID、label 和 section，不输出 value：

```bash
op item get '<item-id>' --vault '<vault>' --format json | python3 -c 'import json,sys; print([{k:f.get(k) for k in ("id", "label", "section")} for f in json.load(sys.stdin).get("fields", [])])'
```

完整条目 JSON 即使没有 `--reveal` 也应按含明文处理。不要裸打印、落盘或将其放入聊天；也不要用 `op read` 把秘密读出来“看一眼”。字段不存在时停止依赖该字段的操作，不用空值继续执行。

## 向命令注入

优先用 `op run`，环境变量名必须是目标程序实际读取的名字。引用中的 vault、item ID、section 和字段来自已核实的条目。下面仅为占位示例：

```bash
PGUSER='op://<vault>/<item-id>/username' \
PGPASSWORD='op://<vault>/<item-id>/password' \
op run -- psql -h '<host>' -c 'select 1'
```

已有引用模板可用 `op run --env-file=<path> -- <command>`。需要 shell 展开时使用 `op run -- sh -c '...'`，让变量在子进程中展开；不要再将秘密展开到下游命令参数里。程序支持 stdin 时可用 stdin，避免秘密进入进程参数、历史或文件。

`op run` 的输出掩码只是尽力保护，转换后的秘密或分段输出可能漏出。禁止通过 `set -x`、打印环境或调试日志验证秘密；只回报退出码和脱敏后的业务结果。

只向本次任务可信的程序提供必要凭据。若已有 `OP_SERVICE_ACCOUNT_TOKEN`，目标程序不需要它时可用 `op run -- env -u OP_SERVICE_ACCOUNT_TOKEN <command>` 限制继承；这并不会让不可信程序变得安全，它仍能读取注入的秘密。

仅在 `op run` 确实不适用时，在内存中捕获 `op read` 的结果并传给目标子进程。检查退出码和空值，不回显，不依赖未经失败检查的命令替换，也不假定这条路径有输出掩码。

## 创建、更新与整理

1. 写入前明确目标 vault、item ID 和本次改动，创建前查重；同名不代表内容相同或可以覆盖。已有授权直接执行，范围不明确时先澄清。
2. 改名或移动前检查已知的 `op://`、脚本及 SSH Agent 引用。`--tags` 替换整组标签，添加标签需合并现有值。写前回读相关元数据，发现并发变化时重新核对。
3. 标题、标签等使用对应 flag；敏感字段在内存中构造 JSON，经 stdin 传入。创建使用 `op item create --vault '<vault>' -`，更新使用 `op item edit '<item-id>' --vault '<vault>'` 接收 stdin，不与 `--template` 混用。捕获并过滤写入返回值、dry-run 和异常，避免泄露完整条目。
4. 含 passkey 的条目不能用完整 JSON 模板更新，模板不能保留 passkey。CLI 不支持 SSH Key 编辑时说明限制，不转换类别或重建密钥绕过。
5. 逐条写入后按 ID 回读，在内存中比较目标字段和应保留的字段，仅输出是否符合预期。超时或错误后先核实是否已经生效，不直接重试创建。重复同类失败且无新增证据时停止，报告已完成、失败和未尝试项。

跨库复制需确认目标位置和内容；整理或复制的授权不自动包含归档、删除源条目。更新密码库中的值不等于完成上游服务的密码或 API key 轮换。

## 参考文档

命令行为以本机帮助及官方文档为准：[凭据注入](https://developer.1password.com/docs/cli/secrets-scripts/)、[条目编辑与 passkey 限制](https://developer.1password.com/docs/cli/item-edit/)。
