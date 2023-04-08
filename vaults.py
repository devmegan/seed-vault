from dotenv import load_dotenv
import os
from flask import Flask, jsonify, render_template
import psycopg2
from tabulate import tabulate

svdb = Flask(__name__)

load_dotenv()
load_dotenv('.env.local', override=True)

db_config = {
    "host": os.environ.get('PGRES_HOST'),
    "database": os.environ.get('DB_NAME'),
    "user": os.environ.get('DB_USERNAME'),
    "password": os.environ.get('DB_PASSWORD')
}


@svdb.route("/")
def index():
    return render_template("index.html")


@svdb.route("/facilities")
def facilities():
    conn = postgres_connect()

    cur = conn.cursor()
    cur.execute("SELECT * FROM facilities ORDER BY country")

    res = cur.fetchall()

    if res:
        headers = ["id", "name", "city", "country"]
        results = [dict(zip(headers, row)) for row in res]
        return render_template("facilities.html", results=results)
    else:
        return render_template("facilities.html", results=None)


def postgres_connect():
    conn = psycopg2.connect(**db_config)
    return conn
