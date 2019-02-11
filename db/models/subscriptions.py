from mongoengine import *


class Subscriptions(Document):
    datasetId=StringField(required=True)
    notificationUrl=StringField(required=True)