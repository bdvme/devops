from time import sleep
from sentry_sdk import Hub, init, start_transaction

init(
    dsn="https://5f3976a16e354034b1f4f77102967602@o4504695596843008.ingest.sentry.io/4504695609753600",
    traces_sample_rate=1.0,
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