# ws-releases

Installer and released binaries for `ws`, the client for the group's remote
OpenStack dev workstations. Source lives in a private repo; only the built
binaries are published here so no GitHub auth is needed to install.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/NeuralQXLab/ws-releases/main/install.sh | sh
```

Then claim your box with the link and passphrase you were sent:

```sh
ws init <link>
ws provision      # github + syncthing setup
ws ssh            # you're in
```

`ws` keeps itself up to date — it checks this repo at most once a day and
replaces its own binary when a newer release exists.
