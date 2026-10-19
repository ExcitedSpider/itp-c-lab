"""Package only the standalone lab for Cloudflare Pages Git deployments."""
import pathlib
import shutil

root = pathlib.Path(__file__).resolve().parent.parent
destination = root / 'dist/static'
destination.mkdir(parents=True, exist_ok=True)
shutil.copyfile(root / 'presentation/index.html', destination / 'index.html')
print('Packaged dist/static/index.html for Cloudflare Pages')
