from flask import Flask
from jinja2 import Environment,  FileSystemLoader, PackageLoader, Template, select_autoescape
import os
import datetime

app = Flask(__name__)

@app.route("/")
def main():
    return "Main Page"
    
@app.route("/hw")
def hello():
    return "Hello World!"	
	
winners = [
    {'name': 'Albert Einstein', 'category': 'Physics'},
    {'name': 'Barack Obama', 'category': 'Politician'},
    {'name': 'Dorothy Hodgkin', 'category': 'Chemistry'}
]

@app.route("/demolist")
def demo_list():
    templateLoader = FileSystemLoader('.')
    templateEnv = Environment(loader=templateLoader)
    TEMPLATE_FILE = os.path.join(os.path.dirname(__file__), '/templates/testj2.html')
    template = templateEnv.get_template(TEMPLATE_FILE)
    return template.render(heading="A Little Winners' List", winners=winners)
    
if __name__ == '__main__':
    app.run(port=8000, debug=True)