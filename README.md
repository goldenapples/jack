# Jack

### (the beanstalk fugitive)

This vim plugin is a start at trying to make the tools which
[vim-fugitive](https://github.com/tpope/vim-fugitive) enables for Github
repositiories functional with Beanstalk git remotes.

From within a file whose "origin" repository is a Beanstalk remote, type
`:Gbrowse` to bring up the current file on the current working branch on
Beanstalk. This should work for all the ref types which fugitive supports.

## Installation

This should work with any vim package manager. For Pathogen installation,
simply clone this repository into your `~/.vim/bundle` directory.

## Issues

This is still very much a work in progress. Please open issues here. Pull
requests are welcome!



*To come:* 
- line highlighting (I need to find documentation on how those links are built
  on Beanstalk...) 
- better support for different git ref types (this works with branch heads and
  commit hashes, but doesn't provide deep links into code review or other
  object types, and doesn't work at all with diff or blame views.
