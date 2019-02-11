try:  # Python 3.5+
    from http import HTTPStatus as HTTPStatus
except ImportError:
    from http import client as HTTPStatus
from flask import Blueprint, jsonify, request
import json
import logging
from v1.db.db import Db
from v1.auth.auth import auth

subscribe = Blueprint('subscribe', 'subscribe')

@subscribe.route('/', methods=['GET'], strict_slashes=False)
@auth
def listSubscriptions() -> object:
    """
    Subscribe to dataset updates
    :return: JSON with subscription ID if successful, error if not
    """

    db = Db()
    return db.Subscriptions.objects().to_json()

@subscribe.route('/', methods=['POST'], strict_slashes=False)
@auth
def subscribePost() -> object:
    """
    Subscribe to dataset updates
    :return: JSON with subscription ID if successful, error if not
    """
    log = logging.getLogger(__name__)
    db = Db()

    body = request.get_json()

    if not('datasetId') in body:
        return jsonify({"error": "datasetId is a required attribute"}), HTTPStatus.INTERNAL_SERVER_ERROR

    if not('notificationUrl') in body:
        return jsonify({"error": "notificationUrl is a required attribute"}), HTTPStatus.INTERNAL_SERVER_ERROR


    subscription = db.Subscriptions(
        datasetId=body['datasetId'],
        notificationUrl=body['notificationUrl']
    )

    subscription.save()

    subscription = json.loads(subscription.to_json())
    subscription['id'] = subscription['_id']["$oid"]
    subscription.pop("_id")
    log.debug("subscription created")

    return jsonify(subscription), HTTPStatus.CREATED