#from flask import Flask
#app = Flask(__name__)

winners = [
	{'name': 'Albert Einstein', 'category': 'Physics'},
	{'name': 'Barack Obama', 'category': 'Politician'},
	{'name': 'Dorothy Hodgkin', 'category': 'Chemistry'}
]

@app.route("/demolist")
def demo_list():
	template = env.get_template('testj2.html')
	return template.render(heading="A Little Winners' List", winners=winners)