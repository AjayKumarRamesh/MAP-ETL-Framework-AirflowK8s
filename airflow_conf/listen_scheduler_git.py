import subprocess, os
from flask import Flask, request, Response

app = Flask(__name__)

@app.route('/scheduler-git/webhook', methods=['POST'])
def respond():
    os.chdir(os.environ['AIRFLOW_GIT'])
    branch = os.environ['BRANCH']
    subprocess.call(['git', 'fetch', '--all'])
    subprocess.call(['git', 'reset', '--hard', 'origin/'+branch])
    subprocess.call(['git', 'pull'])
    subprocess.call(['chmod', '-R', '755', '/opt/airflow/git/dags'])
    return Response(status=200)