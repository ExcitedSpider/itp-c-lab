#!/usr/bin/env python3
"""Record real subprocess evidence inside the experiment containers (stdlib only)."""
import datetime, hashlib, json, os, pathlib, subprocess, sys, time

ROOT = pathlib.Path(__file__).resolve().parent.parent
os.chdir(ROOT)
def capture(label, command, timeout=1800):
    outdir = ROOT / 'results' / 'rework'
    outdir.mkdir(parents=True, exist_ok=True)
    start = time.monotonic()
    try:
        p = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                           text=True, timeout=timeout)
        output, code = p.stdout, p.returncode
    except subprocess.TimeoutExpired as e:
        output = e.stdout or b''
        if isinstance(output, bytes): output = output.decode(errors='replace')
        output += '\nRUNNER TIMEOUT\n'
        code = 124
    except OSError as e:
        output, code = str(e)+'\n', 127
    record = dict(command=command, cwd=str(ROOT), timestamp=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                  exit_code=code, wall_seconds=time.monotonic()-start, output=output)
    (outdir / (label+'.json')).write_text(json.dumps(record, indent=2)+'\n')
    (outdir / (label+'.txt')).write_text('$ '+json.dumps(command)+'\n'+output+'\nExit: '+str(code)+'\n')
    print(label, 'exit', code, 'seconds', round(record['wall_seconds'],3), flush=True)
    print(output[-6000:], flush=True)
    return record

if __name__ == '__main__':
    label, *command = sys.argv[1:]
    sys.exit(capture(label,command)['exit_code'])
