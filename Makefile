# 常用任务
.PHONY: docx clean

docx:
	@python3 -c "import docx" 2>/dev/null || (echo "请先安装依赖: pip install python-docx" && exit 1)
	python3 tools/md2docx.py docs/ai-cad-agent-playbook.zh-CN.md docs/ai-cad-agent-playbook.zh-CN.docx

clean:
	rm -f docs/*.docx.tmp ~\$*.docx
