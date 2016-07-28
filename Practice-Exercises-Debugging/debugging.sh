#!/bin/bash -x

TEST_VAR="test"
echo "$TEST_VAR"

# debugging a script using -x flag

# debugging a part of your script

#!/bin/bash
TEST_VAR="test"
set -x
echo $TEST_VAR
set +x
hostname
# using this you will encapsulate 
# a part of your script for debugging

# built in debugging help

# -e = Exit on error
# Can be combined with other options
#!/bin/bash -ex
#!/bin/bash -xe
#!/bin/bash -e -x
#!/bin/bash -x -e

#!/bin/bash
FILE_NAME="/not/here"
ls $FILE_NAME
echo $FILE_NAME
###

### 
# -v = print commands just like they appear in the script without performing substitutions and expansions.
# -e = exit immediately if a command exits with a non-zero status.
# -x = print commands and their arguments as they will be executed, including substitutions and expansions.

# What variable determines what will be displayed before a command when using the "-x" (or set -x) option?
# PS4