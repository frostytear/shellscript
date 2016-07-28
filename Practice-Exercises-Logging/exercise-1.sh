#!/bin/bash

# logs who, what, when, where, and why

# Linux uses Syslog standard uses facilities and severeties to categorize messages
# Facilities: kern, user, mail, daemon, auth, local0, local7
# Severities: emerg, alert, crit, err, warning, notice, info, debug
# each message have a facilite code and a severetie level

# Log file locations are configurable
# /var/log/messages
# /var/log/syslog

# The logger command generates syslog messages

# Logging with logger
# The logger utility
# By default creates user.notice messages.

#logger "Message"
#logger -p local0.info "Message"
#logger -t myscript -p local0.info "Message"
#logger -i -t myscript "Message"

# logger -p facilities.severities "message"

# if you want to tag you message use -t flag

RANDOM_NUMBER=$RANDOM

logger -t $RANDOM_NUMBER -p user.info "Generating a random number log."