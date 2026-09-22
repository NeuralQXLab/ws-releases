#!/bin/sh
# Moved. ws is now published from the virtualworkstation repo's Pages site.
# This forwarder exists so older links keep working; use the URL below.
set -eu
echo "note: this installer has moved to" >&2
echo "  https://neuralqxlab.github.io/virtualworkstation/install.sh" >&2
echo "forwarding..." >&2
exec sh -c "$(curl -fsSL https://neuralqxlab.github.io/virtualworkstation/install.sh)"
