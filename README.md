# Introduction

Declua is a configuration framework for Neovim designed to
be declarative and flexible.

Your Neovim settings are split into modules written by you and the community. A
module defines options, transformations, and configs which control how Neovim
runs. All module configs are merged together to create your final config.
Configs are typically nested Lua tables. Valid paths through the table are
defined as options. Options define what goes where, configs define what values
are stored in the options, and transformations define how options interact.

Although you can manually create transformations, options, and configs, it's
recommended to use higher level functions instead. For example, there are
functions for defining plugins, simple configs, and more.

## For developers



Declua provides an easy way to create and consume options for your plugin
without introducing any incompatibilities with users not using Declua. Declua
will attempt to source a declua.lua file from your plugin. If that file is
called, you can assume that the `declua` global will exist and contain all the
documented functions and attributes.

As a plugin author, you likely want to create options. You can use the
`declua.addOption` function for that. Your option can modify parts of the
configuration and execute arbitrary lua code when the user's neovim starts.

If you want to add declua support to a plugin you don't own, consider
contributing to the declua ecosystem repository. That repository contains a
variety of options for plugins.

## Declarative

With Declua, your entire configuration becomes a single Lua table. Multiple
configuration tables can be seamlessly merged together from a variety of
sources.

# TODO

1. The current design only really works with a monorepo of modifications and
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
