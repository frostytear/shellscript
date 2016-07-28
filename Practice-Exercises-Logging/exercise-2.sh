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

function logit(){
	RANDOM_NUMBER=$RANDOM
	
	echo "This sctipt generates a syslog LOG"
	echo "You can use: Facilities: kern, user, mail, daemon, auth, local0, local7"
	echo "You can use: Severities: emerg, alert, crit, err, warning, notice, info, debug"

	read -p "Type your Facilitie: " FACILITIE
	read -p "Type your Severitie: " SEVERITIE
	read -p "Type your message: " MESSAGE

	logger -t $RANDOM_NUMBER -p $FACILITIE.$SEVERITIE "${MESSAGE}"
}

logit