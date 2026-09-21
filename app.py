from flask import Flask

app = Flask(__name__)


@app.route("/")
def home():
    return "<h1>Hello, World!</h1><p>Tech Challenge 2 — Montel Quinones</p>"


@app.route("/health")
def health():
    return {"status": "healthy"}, 200


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8000)
    