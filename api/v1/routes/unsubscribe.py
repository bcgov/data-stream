try:  # Python 3.5+
    from http import HTTPStatus as HTTPStatus
except ImportError:
    from http import client as HTTPStatus
from flask import Blueprint, jsonify, request
import json
import logging
from v1.db.db import Db
from v1.auth.auth import auth
from mongoengine import *

unsubscribe = Blueprint('unsubscribe', 'unsubscribe')


@unsubscribe.route('/', methods=['POST'], strict_slashes=False)
@auth
def unsubscribePost() -> object:
    """
    Removes subscriptions from subscription database..
    :return: list of remaining subscriptions
    """
    log = logging.getLogger(__name__)
    log.debug("Beginning deletion")
    db = Db()

    body = request.get_json()
    log.debug(body)
    if body is None:
        return jsonify({"error": "json body is required"}), HTTPStatus.HTTPStatus.BAD_REQUEST

    if not('datasetId') in body:
        return jsonify({"error": "datasetId is a required attribute"}), HTTPStatus.HTTPStatus.BAD_REQUEST

    count = 0
    idArray = json.loads(body['datasetId'])
    log.debug(str(idArray) + " has length " + str(len(idArray)))

    for deleteId in idArray:
        log.debug(deleteId)
        deletion = db.Subscriptions.objects(
            datasetId=deleteId,
            notificationUrl=body['notificationUrl']
        )
        log.debug(deletion)
        deletion.delete()

        count += 1

    return jsonify(str(count) + " records deleted."), HTTPStatus.OK
