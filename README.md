This project is in a proof of concept stage right now.

# Introduction

Declua is a configuration framework for Neovim designed to be declarative and
flexible.

Your Neovim settings are split into modules written by you and the community. A
module defines options, transformations, and configs which control how Neovim
runs. All module configs are merged together to create your final config.
Configs are typically nested Lua tables. Valid paths through the table are
defined as options. Options define what goes where, configs define what values
are stored in the options, and transformations define how options interact.

Although you can manually create transformations, options, and configs, it's
recommended to use higher level functions instead. For example, there are
functions for defining plugins, simple configs, and more.

Interested in what Declua looks like? Take a look at the example folder. If you
want to pull back the curtain a bit, start with the builtinMods file in the lua
folder.

## Declarative

With Declua, your entire configuration becomes a single Lua table. Multiple
configuration tables can be seamlessly merged together from a variety of
sources.

# TODO

1. Declua doesn't actually use the concept of modules anywhere in its
   implementation. I'm currently using module to just mean some Lua file which
   defines options and transformations in one place. Should I change the
   nomenclature at some point or add helper functions for modules to Declua?

2. Error messages are gross right now. If you mess anything up, you get very
   little information and need to do some digging to find out what went wrong. A
   real version of Declua should have friendly error messages even in the face
   of poorly written transformations or options.

3. Some mechanism to search options and transformations would be really cool.

4. The implementation is kind of gross and uses inconsistent naming.

5. Use a file format other than Lua for defining user config files. Load it into
   Lua somewhere. The config format should make it easy to set deeply nested
   tables.

6. Consider rewriting in a language which compiles to Lua.

6. The current design only really works with a monorepo of transformations and
   options. Although convenient for bootstrapping a project, would it be better
   to encourage plugin authors to support Declua in their repositories? If
   Declua wants to be a Neovim distribution of sorts then a monorepo might be a
   good idea. New features can be added to Declua and used by plugins without
   bothering the plugin owners. On the other hand, it shifts the maintenance
   burden in a weird way. Will upstream plugins help with bugs when Declua was
   used to configure everything? Any use of Declua probably doesn't count as a
   minimally reproducible example. If plugin authors were to maintain their own
   Declua configs, they might be more willing to accept bug reports related to
   them.

   Even if plugin authors don't embrace Declua in their own repos, it would
   still be powerful for users to create alternate repos.

# Inspiration

The Nixos module system is a massive inspiration for this. If you think Declua
is a cool way of managing Neovim, consider managing other parts of your Linux or
Mac computer with Nix and/or Nixos.
