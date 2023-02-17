import logging
import sentry_sdk
from sentry_sdk.integrations.logging import LoggingIntegration

sentry_logging = LoggingIntegration( 
    level = logging.INFO,
    event_level = logging.ERROR
)

sentry_sdk.init(
    dsn="https://bb0d445b572949b0a294adcb2a393923@o4504695596843008.ingest.sentry.io/4504695771365376",
    integrations=[sentry_logging],
)

logging.debug("I am ignored")
logging.info("I am a breadcrumb")
logging.error("I am an event", extra=dict(bar=43))
logging.exception("An exception happened")
