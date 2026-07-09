#!/usr/bin/env python3
"""Stop hook:检查最后一条 assistant 回复里有没有「中文汉字紧挨半角标点」。

有就 block,把原因喂回给模型,让它用全角重写。
代码块 / 行内代码 / URL 会先剥掉,避免误伤合法的半角(路径、命令、数字、英文)。
任何异常都放行(exit 0),绝不因为 hook 出错而打断会话。
"""
import sys
import json
import re

# CJK 汉字:扩展 A(3400-4DBF)+ 基本区(4E00-9FFF)+ 兼容表意(F900-FAFF)
CJK = r"[㐀-鿿豈-﫿]"

# 三类高置信度违规:
#   1. 汉字紧跟半角 , . ; : ? !   ——「你好,」应为「你好，」
#   2. 半角 ( 紧跟汉字            ——「(注」应为「（注」
#   3. 汉字紧跟半角 )            ——「文)」应为「文）」
VIOLATION = re.compile(
    r"(?:" + CJK + r"[,.;:?!])"
    r"|(?:\(" + CJK + r")"
    r"|(?:" + CJK + r"\))"
)


def last_assistant_text(path):
    """从 JSONL transcript 里取最后一条 assistant 消息的纯文本。"""
    last = None
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
            except Exception:
                continue
            if obj.get("type") != "assistant":
                continue
            msg = obj.get("message") or {}
            content = msg.get("content")
            if isinstance(content, str):
                text = content
            elif isinstance(content, list):
                parts = [b.get("text", "") for b in content
                         if isinstance(b, dict) and b.get("type") == "text"]
                text = "\n".join(parts)
            else:
                continue
            if text.strip():
                last = text
    return last


def strip_code_and_urls(text):
    """剥掉代码块、行内代码、URL——这些地方的半角是合法的,不该管。"""
    text = re.sub(r"```.*?```", " ", text, flags=re.S)   # 围栏代码块
    text = re.sub(r"`[^`]*`", " ", text)                  # 行内代码
    text = re.sub(r"https?://\S+", " ", text)             # 链接
    return text


def main():
    raw = sys.stdin.read()
    try:
        data = json.loads(raw) if raw.strip() else {}
    except Exception:
        return

    # 防死循环:如果本次 stop 已经是 hook 续写触发的,就不再拦
    if data.get("stop_hook_active"):
        return

    path = data.get("transcript_path")
    if not path:
        return

    try:
        text = last_assistant_text(path)
    except Exception:
        return
    if not text:
        return

    hits = VIOLATION.findall(strip_code_and_urls(text))
    if not hits:
        return

    sample = "、".join(sorted(set(hits))[:6])
    reason = (
        "你刚才的中文回复里用了半角标点（例如：" + sample + "）。"
        "请直接重新输出修正后的完整回复——中文句子的标点一律用全角："
        "，。、；：？！「」（）；代码、路径、数字、纯英文本身保持半角。"
        "不要道歉、不要解释，直接给修正版。"
    )
    print(json.dumps({"decision": "block", "reason": reason}, ensure_ascii=False))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass  # 兜底:任何意外都放行,不打断会话
