import os
import sys

from jupyter_core.paths import jupyter_config_dir

c.NotebookApp.ip = os.environ.get('IPADDRESS', '*')
c.NotebookApp.port = int(os.environ.get('PORT', 8888))
c.NotebookApp.open_browser = False

# Password protection
if os.environ.get('NOTEBOOK_PASSWORD', 'none') != 'none':
    c.NotebookApp.password = os.environ['NOTEBOOK_PASSWORD']
    del os.environ['NOTEBOOK_PASSWORD']

# HTTPS
PEM_FILE = os.path.join(jupyter_config_dir(), 'notebook.pem')

if os.environ.get('USE_HTTPS', 'no') != 'no':
    if not os.path.isfile(PEM_FILE):
        print("USE_HTTPS=yes, but PEM_FILE not found at " + PEM_FILE + ")", file=sys.stderr)
        sys.exit(1);
    else:
        c.NotebookApp.certfile = PEM_FILE

# Remove graphs, and other command output from .ipynb files before
# saving
def scrub_output_pre_save(model, **kwargs):
    """scrub output before saving notebooks"""
    # only run on notebooks
    if model['type'] != 'notebook':
        return
    # only run on nbformat v4
    if model['content']['nbformat'] != 4:
        return

    for cell in model['content']['cells']:
        if cell['cell_type'] != 'code':
            continue
        cell['outputs'] = []
        cell['execution_count'] = None

if os.environ.get('SCRUB_CMD_OUTPUT', 'no') != 'no':
    c.FileContentsManager.pre_save_hook = scrub_output_pre_save
