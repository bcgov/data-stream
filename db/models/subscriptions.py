from mongoengine import *
from datetime import datetime

LAST_NOTIFIED_FORMAT = "%Y,%m,%d,%H,%M,%S,%f"

class Subscriptions(Document):
    datasetId=StringField(required=True)
    notificationUrl=StringField(required=True)
    lastNotified = DateTimeField(required=True, default=datetime.strptime("1990,01,01,00,00,00,000000", LAST_NOTIFIED_FORMAT))
