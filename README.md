# ws — your remote workstation

`ws` connects you to a personal Linux development machine running on the
group's cloud. It's a real box with your own disk: files you leave there stay
there, and you reach it from your laptop over SSH, mosh, or VS Code.

You don't need a cloud account, and you don't manage the machine — someone in
the group sets it up and sends you a claim link.

---

## What you need

- **macOS on Apple Silicon**, or **Linux on x86_64**. (Intel Macs aren't supported.)
- A claim **link** and a **passphrase**, sent to you separately. The link alone
  is useless without the passphrase, and vice versa.
- Optional but recommended: [VS Code](https://code.visualstudio.com/),
  [mosh](https://mosh.org/) for connections that survive suspend and wifi
  changes, and [Syncthing](https://syncthing.net/) if you want files mirrored
  to your laptop.

## Install

```sh
curl -fsSL https://neuralqxlab.github.io/ws-releases/install.sh | sh
```

This drops a single binary in `~/.local/bin`. No sudo, no dependencies. If the
installer says that directory isn't on your `PATH`, add the line it prints to
your shell's rc file and open a new terminal.

`ws` keeps itself up to date — it checks for a new version at most once a day
and replaces itself silently. You never need to reinstall.

## Claim your box

```sh
ws init <the link you were sent>
```

It will ask for the passphrase. This unpacks your bundle into
`~/.config/ws/`: an SSH key that belongs to you and nobody else, plus your
box's address. It's a one-time step.

## Set it up

```sh
ws provision
```

Two things happen, and both need you present:

1. **GitHub** — opens `gh auth login` on the box so you can push and pull from
   private repositories there.
2. **Syncthing** — pairs a folder on the box with one on your laptop, so the
   files you care about exist in both places. It asks where to put the local
   copy and suggests a default.

You can re-run either on its own later with `ws setup github` or
`ws setup syncthing`.

## Everyday use

| command | what it does |
|---|---|
| `ws ssh` | a shell on the box |
| `ws ssh <cmd>` | run one command and come back |
| `ws mosh` | same, but survives suspending your laptop or changing network |
| `ws code` | open the box's `~/work` in VS Code |
| `ws status` | is it reachable? |

`ws mosh` is usually the nicer way to work: close your laptop, open it on a
different network, and your session is still there.

## Where to put your files

**`~/work`** is your workspace. It's what `ws code` opens, and it's on the
persistent disk.

Inside it, one folder is **mirrored to your laptop by Syncthing** — the one
`ws provision` set up. Files there exist in two places, so a dead box costs you
nothing. Everything else on the box exists only on the box.

A practical split:

- **Code** → a git repository. Push it. This is the real backup.
- **Data and results you'd hate to lose** → the synced folder.
- **Scratch, caches, large intermediate files** → anywhere in `~/work`.
  Regenerable, and keeping them out of sync keeps sync fast.

## What's already installed

git, zsh, tmux, mosh, direnv, ripgrep, fd, bat, htop, jq, rsync, build
tooling, `uv` for Python, Node, the GitHub CLI, and Claude Code. Your shell is
zsh with a configured prompt and history.

Install anything else yourself — you have sudo on your own box.

## Troubleshooting

**`ws status` says NOT reachable.**
The most likely reason is that your box is *parked*: to avoid burning compute
when nobody's using it, an idle box gets shut down while keeping its disk
intact. **Waking it up isn't something `ws` can do — ask whoever set up your
box.** Your files are safe; parking never touches the disk.

If it isn't parked, check your own network first (a VPN or a restrictive
firewall will block SSH), then ask.

**The installer fails on an Intel Mac.**
Not supported. Apple Silicon or Linux only.

**Syncthing pairing fails.**
Syncthing has to be installed *and already running* on your laptop before
`ws setup syncthing` — it reads the local configuration to find your device.
Install it (`brew install syncthing`, or your package manager), start it once,
then re-run.

**Syncthing isn't syncing.**
Sync stops while the box is parked and resumes when it's woken. If the box is
up and sync still seems stuck, open the Syncthing UI on your laptop
(usually <http://127.0.0.1:8384>) and check whether the box shows as connected.

**VS Code can't connect.**
`ws code` needs the `code` command on your `PATH`. In VS Code: Command Palette →
*Shell Command: Install 'code' command in PATH*.

**I think I leaked my key.**
Say so immediately. Your key is specific to your box and can be revoked and
reissued without affecting anyone else.

## Good habits

- **Push your code.** The box is a workstation, not an archive.
- **Don't leave a heavy job running** unless you mean to — a parked box saves
  the group real money, and something pinned at 100% CPU keeps it awake.
- **Don't copy private SSH keys onto the box.** If you need to reach an HPC
  cluster from it, ask — there's a way to do that using your laptop's keys
  without the key ever landing on the box.
- **A runaway process won't kill the box.** There's a guard that kills the
  biggest memory hog before the machine wedges. If something vanishes
  mid-run, that's probably why — it ran out of memory.
