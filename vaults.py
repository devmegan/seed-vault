from flask import Flask

svdb = Flask(__name__)

@svdb.route("/")
def index():
    return "<h1>SVDB</h1><p>The Seed Vault Database</p>"
