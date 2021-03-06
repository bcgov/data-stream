try:  # Python 3.5+
    from http import HTTPStatus as HTTPStatus
except ImportError:
    from http import client as HTTPStatus
import logging
import pkg_resources  # part of setuptools
import config
import json

from flask import Flask, g, jsonify, make_response, Response, request
from flask_compress import Compress
import v1.v1 as v1


def create_app(test_config=None):
    log = logging.getLogger(__name__)

    app = Flask(__name__)

    conf = config.Config()
    if test_config is None:
        app.config.update(conf.conf.data)
    else:
        # load the test config if passed in
        app.config.update(conf.conf.data)
        app.config.update(test_config)

    ##Routes##
    v1.Register(app)
    Compress(app)

    @app.before_request
    def before_request():
        from timeit import default_timer as timer

        g.request_start_time = timer()
        g.request_time = lambda: "%s" % (timer() - g.request_start_time)

    @app.after_request
    def after_request(response):
        log.debug('Rendered in %ss', g.request_time())
        return response

    @app.errorhandler(HTTPStatus.NOT_FOUND)
    def not_found(param):
        content = jsonify({
            "error": "Not Found",
            "code": HTTPStatus.NOT_FOUND
        })
        return make_response(content, HTTPStatus.NOT_FOUND)

    @app.errorhandler(HTTPStatus.INTERNAL_SERVER_ERROR)
    def internal_server_error(error):
        content = jsonify({
            "error": "{error}",
            "code": HTTPStatus.INTERNAL_SERVER_ERROR
        })
        return make_response(content, HTTPStatus.INTERNAL_SERVER_ERROR)

    @app.route('/', methods=['GET'], strict_slashes=False)
    def index():
        """
        Return name of api
        :return: name of api
        """

        return jsonify({
            "name": pkg_resources.require("DataStreamApi")[0].project_name
        })

    @app.route('/test', methods=['POST'], strict_slashes=False)
    def test():
        """
        test endpoint for callbacks
        :return: {ok:ok}
        """

        body = request.get_json()
        files = request.files

        log.debug("Files? "+str(len(files)))
        if not(body is None):
            log.debug("Dataset ID: " + body['datasetId'])

        if 'data' in body:
            log.debug(body['data'])


        return jsonify({
            "ok": "OK"
        }), HTTPStatus.ACCEPTED

    @app.route('/version', methods=['GET'], strict_slashes=False)
    def version():
        """
        Get the current version of the api
        """
        from os import environ
        hash = ""
        if environ.get('GITHASH') is not None:
            hash = environ.get("GITHASH")

        v = pkg_resources.require("DataStreamApi")[0].version

        version = v
        if hash != "":
            version += "-" + hash

        responseObj = {
            "v": v,
            "hash": hash,
            "version": version,
        }
        return jsonify(responseObj)

    #code for webpage demo, move to where it is appropriate

    return app
