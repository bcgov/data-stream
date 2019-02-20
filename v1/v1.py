from flask import Blueprint, jsonify
from v1.routes.docs import docs
from v1.routes.subscribe import subscribe
from v1.routes.notify import notify


v1 = Blueprint('v1', 'v1')

@v1.route('/status', methods=['GET'], strict_slashes=False)
def status():
    """
    Returns the overall API status
    :return: JSON of endpoint status
    """
    return jsonify({"status": "ok"})


class Register:
    def __init__(self, app):
        app.register_blueprint(v1, url_prefix="/v1")
        app.register_blueprint(subscribe, url_prefix="/v1/subscribe")
        app.register_blueprint(notify, url_prefix="/v1/notify")
        app.register_blueprint(docs, url_prefix="/v1/api-docs")
