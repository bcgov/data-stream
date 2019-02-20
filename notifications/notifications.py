try:  # Python 3.5+
    from http import HTTPStatus as HTTPStatus
except ImportError:
    from http import client as HTTPStatus
#from multiprocessing import Process
import _thread
import requests
import logging
import os
import shapefile
import math
import json
import pandas
from datetime import datetime
from v1.db.db import Db
from config import Config


class Notifications:

    @staticmethod
    def triggerNotifications(dataId):
        _thread.start_new_thread(triggerNotifications, (dataId,))
        return None, "Started notifications"


# sample Data id
# fa542137-a976-49a6-856d-f1201adb2243/resource/dc1098a7-a4b8-49a3-adee-9badd4429279/download/mbl_databc_6dec2018.csv
def triggerNotifications(dataId):

    # make request to subscription.notificationUrl with data
    log = logging.getLogger(__name__)
    db = Db()
    subs = db.Subscriptions.objects(datasetId=dataId)

    if len(subs)<=0:
        log.debug("No subscriptions for this datafile")
        return

    fileShortCircuit = "file://"
    data = ""
    filename = dataId[dataId.rfind("/")::]
    isAFile = False
    type = ""

    if dataId[0:len(fileShortCircuit)] == fileShortCircuit:
        currDir = os.path.dirname(os.path.realpath(__file__))
        path = currDir + "/../datasets/" + dataId[len(fileShortCircuit)::]

        if os.path.isfile(path):
            extension = dataId[dataId.rfind(".") + 1::]
            if extension == "csv":
                data = pandas.read_csv(path, header=None)
                type = "csv"
            elif extension == "shp":
                data = shapefile.Reader(path)
                type = "shp"
            else:
                try:
                    with open(path) as f:
                        for line in f.readlines():
                            data = data + line
                except Exception as e:
                    log.error("Error reading file")
                    log.error(e)
                    isAFile = True
                    data = open(path, 'rb')
        else:
            err = "File specified, file does not exist"
            log.error(err)
            return
    else:
        config = Config()
        if not ('dataUrl' in config.data):
            err = "Data Url not specified in API"
            log.error(err)
            return

        url = config.data['dataUrl'] + dataId
        r = requests.get(url)
        if r.status_code == HTTPStatus.OK:
            data = r.text
        else:
            err = "Couldn't download data from url"
            log.error(err)
            return

    for subscription in subs:
        log.debug("Starting thread")
        _thread.start_new_thread(__notify, (subscription, dataId, data, filename, isAFile, type))
        # Requests is broken in multi processes need to use threads
        #proc = Process(target=notify, args=(subscription, dataId, data))
        #proc.start()

    return

def __mockDate(origDatetime, dateFormat):
    currDate = origDatetime
    if isinstance(origDatetime, str):
        currDate = datetime.strptime(origDatetime, dateFormat)

    tDate = datetime.now()
    currDate = currDate.replace(year=tDate.year, month=tDate.month)

    return currDate

def __shpToJson(dict):
    return json.dumps({"type": "FeatureCollection", "features": dict}, default=str)

# was loaded with pyshape
def __filterShp(shapeReader, subscription):
    log = logging.getLogger(__name__)
    fields = shapeReader.fields[1:]
    fieldNames = [field[0] for field in fields]
    buffer = []

    dateField = ""
    dateFormat = "%Y-%m-%d"

    if "TRACK_DATE" in fieldNames:
        dateField = "TRACK_DATE"
        dateFormat = "%Y-%m-%d"
    elif "IGNITION_D" in fieldNames:
        dateField = "IGNITION_D"
        dateFormat = "%Y-%m-%d"
    else:
        log.debug(fieldNames)



    for shape in shapeReader.shapeRecords():

        # MOCKING REMOVE IF MAKING REAL
        try:
            currDate = __mockDate(shape.record[dateField], dateFormat)
            shape.record[dateField] = currDate
        except Exception as e:
            if str(e) != "day is out of range for month":
                log.error("Error mocking date...")
                log.error(e)



        if not(dateField == ""):
            if datetime.combine(shape.record[dateField], datetime.min.time()) <= subscription.lastNotified:
                log.debug("TRUNCATING RECORD - OLDER THAN NOTIFICATION")
            elif datetime.combine(shape.record[dateField], datetime.min.time()) > datetime.now():
                log.debug("TRUNCATING RECORD - HASN'T HAPPENED YET")
            else:
                atr = dict(zip(fieldNames, shape.record))
                geom = shape.shape.__geo_interface__

                buffer.append(dict(type="Feature",
                                   geometry=geom, properties=atr))
        else:
            atr = dict(zip(fieldNames, shape.record))
            geom = shape.shape.__geo_interface__

            buffer.append(dict(type="Feature",
                               geometry=geom, properties=atr))

    return buffer


# was loaded with pandas
def __filterCsv(data, subscription):

    now = datetime.now()

    # mocking
    data[0] = now.year
    data[1] = now.month

    newColPos = len(data.columns)

    data[newColPos] = data[0].map(str) + "/" + data[1].map(str) + "/" + data[2].map(str) + " " + data[3].map(str) + ":" + data[4].map(str) + ":" + data[5].map(str) + "." + data[6].map(str)
    data[newColPos] = pandas.to_datetime(data[newColPos], format="%Y/%m/%d %H:%M:%S.%f", errors='coerce')

    #remove the things that were coerced
    isValid = data[newColPos].notnull()
    data = data[isValid]

    # date in range
    dateAbove = data[newColPos] > subscription.lastNotified

    # mocking below
    dateBelow = data[newColPos] < now

    data = data[dateAbove]
    data = data[dateBelow]

    data = data.drop(columns=[newColPos])


    return data


def __csvToJson(data):
    return data.to_json()

# ideally chunk division should be factored up a level to load less of the file into memory HOWEVER file is debug, and
# the url response is going to be in memory anyways
def __notify(subscription, dataId, data, filename, isAFile, type):
    log = logging.getLogger(__name__)

    config = Config()
    ##note that since data is of type string each char is a byte so this is actually 8*?
    chunkSize = 1024
    if "chunkSize" in config.data:
        chunkSize = config.data["chunkSize"]

    db = Db()

    #filter data if we know how
    if type == "shp":
        fields = data.fields[1:]
        fieldNames = [field[0] for field in fields]
        buffer = []

        data = __filterShp(data, subscription)
        data = __shpToJson(data)
    elif type == "csv":
        data = __filterCsv(data, subscription)
        data = __csvToJson(data)


    if isAFile:
        log.debug("isAFile sub route")
        jsonD = {
            "datasetId": dataId,
            "subscriptionId": str(subscription.id),
            "filename": filename,
            "file": True
        }
        r = requests.post(subscription.notificationUrl, json=jsonD, files={'file': data})
        if r.status_code == HTTPStatus.OK:
            log.debug("Url returned 200")
            subscription.lastNotified = datetime.now()
            subscription.save()
        elif r.status_code == HTTPStatus.ACCEPTED:
            log.debug("Url returned 202")
            subscription.lastNotified = datetime.now()
            subscription.save()
        elif r.status_code == HTTPStatus.NOT_ACCEPTABLE:
            log.debug("Url returned " + str(int(HTTPStatus.NOT_ACCEPTABLE)) + ", removing subscription")
            db.Subscriptions.objects(id=str(subscription.id)).delete()
        return



    chunks = math.ceil(len(str(data))/chunkSize)

    for partNo in range(0, chunks):
        log.debug("Part " + str(partNo))
        startChunk = partNo*chunkSize
        endChunk = (partNo+1)*chunkSize
        chunkedData = data[startChunk:endChunk]


        jsonD = {
            "datasetId": dataId,
            "subscriptionId": str(subscription.id),
            "filename": filename,
            "part": (partNo+1),
            "chunks": chunks,
            "data": chunkedData
        }

        log.debug("Calling " + subscription.notificationUrl)

        r = requests.post(subscription.notificationUrl, json=jsonD)

        if r.status_code == HTTPStatus.OK:
            log.debug("Url returned 200")
            if (partNo + 1) == chunks:
                subscription.lastNotified = datetime.now()
                subscription.save()
        elif r.status_code == HTTPStatus.ACCEPTED:
            log.debug("Url returned 202")
            if (partNo + 1) == chunks:
                subscription.lastNotified = datetime.now()
                subscription.save()
        elif r.status_code == HTTPStatus.NOT_ACCEPTABLE:
            if (partNo+1) == chunks:
                log.debug("Url returned " + HTTPStatus.NOT_ACCEPTABLE + ", removing subscription")
                db.Subscriptions.objects(id=str(subscription.id)).delete()
            else:
                log.debug("Url returned 204, NOT removing as it's not the final chunk")

        else:
            log.error("Error notifying " + subscription.notificationUrl + ": " + str(r.status_code))