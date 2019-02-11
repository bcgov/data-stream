from multiprocessing import Process
import requests, logging

def notify(subscription, data):
    #make request to subscription.notificationUrl with data
    log = logging.getLogger(__name__)
    r = requests.post(subscription.notificationUrl, data=data)
    if r.status_code == 200:
        log.debug("Url returned 200")
    elif r.status_code == 202:
        log.debug("Url returned 202")
    elif r.status_code == 204:
        log.debug("Url returned 204, removing subscription")
        subscription.delete()
    else:
        log.error("Error notifying " + subscription.notificationUrl + ": " + r.status_code)


def triggerNotifications(data):
