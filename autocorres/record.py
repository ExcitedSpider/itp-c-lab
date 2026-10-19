"""Capture real retained Isabelle command states; no proof-text emulation."""
import hashlib
import json
import pathlib
import re
import sys
import xml.etree.ElementTree as ET

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'results'))
from capture import capture

for n in range(1, 6):
    source = f'autocorres/p{n}/P{n}.thy'
    text = (ROOT / source).read_text()
    digest = hashlib.sha256((ROOT / source).read_bytes()).hexdigest()
    xml = ROOT / f'results/rework/autocorres-p{n}-states.xml'
    xml.unlink(missing_ok=True)
    argv = ['/home/isabelle/Isabelle/bin/isabelle', 'build', '-c', '-o', 'threads=2',
            '-d', '/home/isabelle/afp-2026-10-16/thys', '-d', 'autocorres/recording',
            f'C_ITP_Record_P{n}']
    result = capture(f'autocorres-record-p{n}', argv)
    if result['exit_code'] != 0:
        raise RuntimeError(f'P{n} recording failed; see captured build log')
    tree = ET.parse(xml).getroot()
    # Isabelle positions count escaped symbols such as \\<Longrightarrow> once.
    offsets = [m.start() for m in re.finditer(r'\\<[^>]+>|[\s\S]', text)] + [len(text)]
    steps = []
    for node in tree:
        name = node.attrib['name']
        if name == '<ignored>':
            continue
        start = offsets[int(node.attrib['start_symbol']) - 1]
        end = offsets[int(node.attrib['end_symbol']) - 1]
        command = text[start:end]
        assert command.strip() and command.lstrip().startswith(name), (name, command)
        output = node.findtext('output') or ''
        steps.append(dict(command=command, start=start, end=end, line=int(node.attrib['line']),
                          output=output, goal_output=output, proof_open=node.attrib['proof_open']=='true',
                          command_name=name, inspection_query='Toplevel.pretty_state',
                          raw_response=output))
    assert steps[-1]['command_name'] == 'end' and not steps[-1]['proof_open']
    assert any(s['proof_open'] and s['output'] for s in steps)
    assert any('Thm_Deps.all_oracles' in s['command'] for s in steps)
    assert digest == hashlib.sha256((ROOT / source).read_bytes()).hexdigest()
    record = dict(tool='AutoCorres2', language='isabelle', checker='Isabelle2025-2',
                  source=source, source_text=text, source_sha256=digest, argv=argv,
                  cwd=str(ROOT), steps=steps, total_seconds=result['wall_seconds'], exit_code=0,
                  mode='Retained theory states after each actual Isabelle command',
                  theory=tree.attrib['theory'], evidence=f'results/rework/autocorres-record-p{n}.txt',
                  raw_states=str(xml.relative_to(ROOT)),
                  output_scope='Toplevel.pretty_state only; full session stdout is in evidence')
    dest = ROOT / f'results/rework/proof-states/autocorres/P{n}.json'
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(json.dumps(record, indent=2, ensure_ascii=False)+'\n')
    print(f'P{n}: saved {len(steps)} checked command states', flush=True)
