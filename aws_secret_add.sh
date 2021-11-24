#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2021-11-24 12:40:18 +0000 (Wed, 24 Nov 2021)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
. "$srcdir/lib/aws.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Reads a value from the command line and saves it to AWS Secrets Manager without echo'ing it on the screen

First argument is used as secret name - if not given prompts for it
Second argument is used as secret string value - if not given prompts for it with a non-echo'ing prompt (recommended)
Third or more args are passed to 'aws secretsmanager'


$usage_aws_cli_required
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<name> [<secret> --description 'blah' <more_aws_options>]"

help_usage "$@"


name="${1:-}"
value="${2:-}"
shift || :
shift || :

if [ -z "$name" ]; then
    read -r -p "Enter name: " name
fi

if [ -z "$value" ]; then
    # doesn't echo, let's print a star per character instead as it's nicer feedback
    #read -s -p "Enter value: " value

    value=""
    prompt="Enter value: "
    while IFS= read -p "$prompt" -r -s -n 1 char; do
        if [[ "$char" == $'\0' ]]; then
            break
        fi
        prompt='*'
        value="${value}${char}"
    done
    echo
fi

aws secretsmanager create-secret --name "$name" --secret-string "$value" "$@"