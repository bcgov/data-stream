try:  # Python 3.5+
    from http import HTTPStatus as HTTPStatus
except ImportError:
    from http import client as HTTPStatus
from flask import Blueprint, jsonify, request, abort
from v1.auth.auth import auth
from v1.notifications.notifications import Notifications

notify = Blueprint('notify', 'notify')

@notify.route('/', methods=['POST'], strict_slashes=False)
@auth
def subscribePost() -> object:


    if request.headers['id'] != 'admin':
        abort(401)

    body = request.get_json()

    if not('datasetId') in body:
        return jsonify({"error": "datasetId is a required attribute"}), HTTPStatus.BAD_REQUEST

    datasetId = body['datasetId'].replace('"', "")

    err, message = Notifications.triggerNotifications(datasetId)

    if not(err is None):
        return jsonify({"error": err}), HTTPStatus.INTERNAL_SERVER_ERROR


    return jsonify({"message": message}), HTTPStatus.OK
