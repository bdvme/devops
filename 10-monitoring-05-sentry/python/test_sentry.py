import logging
import sentry_sdk
from sentry_sdk.integrations.logging import LoggingIntegration

sentry_logging = LoggingIntegration( 
    level = logging.INFO,
    event_level = logging.ERROR
)

sentry_sdk.init(
    dsn="https://{token}.ingest.sentry.io/{id}",
    integrations=[sentry_logging],
)

logging.debug("I am ignored")
logging.info("I am a breadcrumb")
logging.error("I am an event", extra=dict(bar=43))
logging.exception("An exception happened")
