# Boxen

Manage Mac development boxes with love (and Puppet).

## Rules for Services

0. Run on a nonstandard port, usually default port + 1000 or 10000.

0. Install with a custom Boxen homebrew formula.

0. Suffix the Homebrew package's version, starting with `-boxen1`.

0. Run as a launchd service in the `com.boxen` namespace, e.g.,
   `com.boxen.dnsmasq`.

0. Store config, data, and log files in
   `$BOXEN_HOME/{config,data,log}. This will normally require
   customization of a service's Homebrew formula.

Sometimes it's not possible to follow these rules, but try hard.

## Contributing

Use the OS X system Ruby (1.8.7). Run `script/tests` often. Open PR's.

### Managing Boxen's Puppet Modules

There are roughly nine million puppet modules under the
[Boxen GitHub organization][boxen]. To clone them all, run
`script/sync-puppet`. This script will make sure every
`boxen/puppet-*` repo is cloned under the `./puppet` directory, which is
ignored by Git.

[boxen]: https://github.com/boxen

Because it uses the GitHub API, `script/sync-puppet` will prompt you
for your login and password. It'll use them to create an OAuth token
and stash it in `.github-oauth-token` for future use.