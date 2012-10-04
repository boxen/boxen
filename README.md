# Boxen

Manage development boxes with love (and Puppet).

## Contributing

Use the OS X system Ruby (1.8.7). Run `script/tests` often. Open PR's.

### Managing Boxen's Puppet Modules

There are roughly nine million puppet modules under the
[Boxen GitHub organization][boxen]. To clone them all, run
`script/sync-puppet`. This script will make sure every
`boxen/puppet-*` repo is cloned under the `./puppet`, which is ignored
by Git.

[boxen]: https://github.com/boxen

Because it uses the GitHub API, `script/sync-puppet` requires the
`GITHUB_LOGIN` and `GITHUB_PASSWORD` environment variables to be set.
If you don't want to provide them every time, you can set them in
`.env.local.rb`, which is also ignored by Git. For example, your
`.env.local.rb` might look like this:

```ruby
ENV["GITHUB_LOGIN"]    = "jbarnette"
ENV["GITHUB_PASSWORD"] = "adventures"
```
