from functools import wraps
from flask import request, abort, Response
from config import Config
import logging

def auth(f):
    """
    @param f: flask function
    @return: decorator, return the wrapped function or abort json object.
    """

    @wraps(f)
    def decorated(*args, **kwargs):
        log = logging.getLogger(__name__)
        config = Config()

        if not('id' in request.headers):
            log.error("Unauthorized address trying to use API: " + request.remote_addr)
            abort(401)

        if not('x-api-key' in request.headers):
            log.error("Unauthorized address trying to use API: " + request.remote_addr)
            abort(401)

        id = request.headers.get('id')

        if config.data['apiSecret'][id] == request.headers.get('x-api-key'):
            return f(*args, **kwargs)
        else:
            log.error("Unauthorized address trying to use API: " + request.remote_addr)
            abort(401)

    return decorated
