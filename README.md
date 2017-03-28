# JACK

### (the beanstalk fugitive)

This vim plugin is a start at trying to make the tools that
[vim-fugitive](https://github.com/tpope/vim-fugitive) enables for Github
working with Beanstalk git remotes.

From within a file whose "origin" repository is a Beanstalk remote, type
`:Gbrowse` to bring up the current file on the current working branch on
Beanstalk.

To come: line highlighting (I need to find documentation on how that's done on
Beanstalk), and beter support for different git ref types (this works with
branch heads and commit hashes, but doesn't provide deep links into code review
or other object types, and doesn't work at all with diff or blame views.)
