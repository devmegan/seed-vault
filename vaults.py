from dotenv import load_dotenv
import os
from flask import Flask, render_template
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


@svdb.route("/facilities/<int:facility_id>")
def get_facility(facility_id):
    conn = postgres_connect()

    cur = conn.cursor()
    cur.execute("""
        SELECT facilities.*, COUNT(seeds.id) as num_seeds
        FROM facilities
        LEFT JOIN facilities_seeds ON facilities.id = facilities_seeds.facility_id
        LEFT JOIN seeds ON facilities_seeds.seed_id = seeds.id
        WHERE facilities.id = %s
        GROUP BY facilities.id
    """, (facility_id,))

    res = cur.fetchall()

    if res:
        facility = {
            "name": res[0][1],
            "city": res[0][2],
            "country": res[0][3],
            "count": res[0][4]
        }

        return render_template("facility.html", facility=facility)
    else:
        return render_template("facility.html", facility=None, id=facility_id)


def postgres_connect():
    conn = psycopg2.connect(**db_config)
    return conn
