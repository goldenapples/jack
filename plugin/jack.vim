function! s:beanstalk_url(opts, ...) abort
  if a:0 || type(a:opts) != type({})
    return ''
  endif

  " Get the organization under which the repo is located
  let organization = matchstr(get(a:opts, 'remote'), '^\(git@\)\zs\(\w\+\)\ze\(\.git\.beanstalkapp\.com:\)' ) 
  " Get the remote repository name
  let repo = matchstr(get(a:opts, 'remote'), '^\(git@'.organization.'\.git\.beanstalkapp\.com:/'.organization.'/\)\zs\([^/]\+\)\ze\.git$')

  if organization ==# '' || repo ==# ''
    return ''
  endif

  " Web root of repository on Beanstalk
  let root = 'https://' . organization . '.beanstalkapp.com/' . repo

  " Path from the git root to the current file
  let path = substitute(a:opts.path, '^/', '', '')

  if path =~# '^\.git/refs/heads/'
    let branch = a:opts.repo.git_chomp('config','branch.'.path[16:-1].'.merge')[11:-1]
    
    if branch ==# ''
      return root . '/changesets/' . path[16:-1]
    else
      return root . '/' . branch
    endif
  elseif path =~# '^\.git/refs/tags/'
    return root . '?ref=t-' . path[15:-1]
  elseif path =~# '^\.git/refs/remotes/[^/]\+/.'
    return root . '/changesets/' . matchstr(path,'remotes/[^/]\+/\zs.*')
  elseif path =~# '.git/\%(config$\|hooks\>\)'
    return root
  elseif path =~# '^\.git\>'
    return root
  endif

  " Try and guess the appropriate type of link to build (c-commit/b-branch/t-tag...)
  if a:opts.commit =~# '^\d\=$'
    let commit = a:opts.repo.rev_parse('HEAD')
  else
    let commit = a:opts.commit
  endif
  if get(a:opts, 'type', '') ==# 'tree' || a:opts.path =~# '/$'
    let url = substitute(root . '?ref=c-' . commit, '/$', '', 'g')
  elseif get(a:opts, 'type', '') ==# 'blob' || a:opts.path =~# '[^/]$'
    let url = root . '/browse/git/' . path . '?ref=c-' . commit

    " line1 and line2 represent selected lines, and ideally should be
    " highlighted in the target window. This is not working yet; I have an
    " open support ticket with Beanstalk to figure it out - not sure yet if
    " it's possible.
    if get(a:opts, 'line2') && a:opts.line1 == a:opts.line2
      let url .= PathGuid(path, a:opts.line1)
    elseif get(a:opts, 'line2')
      let url .= PathGuid(path, a:opts.line1 + ':' + a:opts.line2) 
    endif
  else
    let url = root . '/changesets/' . commit
  endif
  return url
endfunction

function! PathGuid(filepath, linenum)
  if has('ruby')
    if !exists('s:loaded_ruby_zlib')
      ruby require 'zlib'
      let s:loaded_ruby_zlib = 1
    endif
    ruby <<EOF
      hash1 = Zlib.crc32( VIM::evaluate('a:filepath' ) )
      hash2 = Zlib.crc32( VIM::evaluate('a:linenum' ).to_s )
      hashsum = (hash1 + hash2).to_s
      VIM::command('let decstr = "#L' + hashsum + '"')
EOF
    return decstr
  else
    throw 'Vim must be compiled with Ruby support to use crc32 functions'
  endif
endfunction

function! s:function(name) abort
  return function(substitute(a:name,'^s:',matchstr(expand('<sfile>'), '<SNR>\d\+_'),''))
endfunction

let g:fugitive_browse_handlers = [s:function('s:beanstalk_url')]

" vi:et sts=2 ts=2 sw=2
