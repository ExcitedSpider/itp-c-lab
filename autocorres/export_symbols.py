"""Export the installed Isabelle distribution's Unicode symbol mapping."""
import json
import pathlib
import re

root = pathlib.Path(__file__).resolve().parent.parent
source = pathlib.Path('/home/isabelle/Isabelle/etc/symbols')
symbols = {name: chr(int(code, 16)) for name, code in
           re.findall(r'^(\\<[^>]+>)\s+code:\s+0x([0-9a-fA-F]+)', source.read_text(), re.M)}
(root / 'presentation/isabelle-symbols.json').write_text(
    json.dumps(symbols, ensure_ascii=False, indent=2)+'\n')
print(f'Exported {len(symbols)} Unicode mappings from {source}')
