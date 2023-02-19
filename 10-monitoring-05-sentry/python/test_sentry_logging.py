import logging
from time import sleep
from sentry_sdk import Hub, init, start_transaction
from sentry_sdk.integrations.logging import LoggingIntegration

sentry_logging = LoggingIntegration( 

    level = logging.INFO,
    event_level = logging.ERROR
)

init(
    dsn="https://{token}.ingest.sentry.io/{id}",
    traces_sample_rate=1.0,
    integrations=[sentry_logging],
)

def sentry_trace(func):
    def wrapper(*args, **kwargs):
        transaction = Hub.current.scope.transaction
        if transaction:
            with transaction.start_child(op=func.__name__):
                return func(*args, **kwargs)
        else:
            with start_transaction(op=func.__name__, name=func.__name__):
                return func(*args, **kwargs)
    return wrapper

@sentry_trace
def b():
    for i in range(1000):
        print(i)
        if(i == 400):
            i = i / (i - 400)

@sentry_trace
def c():
    sleep(2)
    print(1)

@sentry_trace
def a():
    sleep(1)
    b()
    c()

if __name__ == '__main__':
    a()
