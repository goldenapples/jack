function! s:beanstalk_url(opts, ...) abort
  if a:0 || type(a:opts) != type({})
    return ''
  endif
  let organization = matchstr(get(a:opts, 'remote'), '^\(git@\)\zs\(\w\+\)\ze\(\.git\.beanstalkapp\.com:\)' ) "/\([^/:]\+\)/\([^/]\+\)\%(\.git\)\=$')
  let repo = matchstr(get(a:opts, 'remote'), '^\(git@'.organization.'\.git\.beanstalkapp\.com:/'.organization.'/\)\zs\([^/]\+\)\ze\.git$')
  if organization ==# '' || repo ==# ''
    return ''
  endif
  let path = substitute(a:opts.path, '^/', '', '')
  let root = 'https://' . organization . '.beanstalkapp.com/' . repo . '/browse/git/' . path

  if path =~# '^\.git/refs/heads/'
    let branch = a:opts.repo.git_chomp('config','branch.'.path[16:-1].'.merge')[11:-1]
    if branch ==# ''
      return root . '?ref=c-' . path[16:-1]
    else
      return root . '?ref=c-' . branch
    endif
  elseif path =~# '^\.git/refs/tags/'
    return root . '?ref=t-' . path[15:-1]
  elseif path =~# '^\.git/refs/remotes/[^/]\+/.'
    return root . '?ref=c-' . matchstr(path,'remotes/[^/]\+/\zs.*')
  elseif path =~# '.git/\%(config$\|hooks\>\)'
    return root
  elseif path =~# '^\.git\>'
    return root
  endif

  if a:opts.commit =~# '^\d\=$'
    let commit = a:opts.repo.rev_parse('HEAD')
  else
    let commit = a:opts.commit
  endif
  if get(a:opts, 'type', '') ==# 'tree' || a:opts.path =~# '/$'
    let url = substitute(root . '?ref=c-' . commit, '/$', '', 'g')
  elseif get(a:opts, 'type', '') ==# 'blob' || a:opts.path =~# '[^/]$'
    let url = root . '?ref=c-' . commit
    if get(a:opts, 'line2') && a:opts.line1 == a:opts.line2
      let url .= '#L' . a:opts.line1  " not working yet
    elseif get(a:opts, 'line2')
      let url .= '#L' . a:opts.line1 . '-L' . a:opts.line2 " not working yet, probably not possible
    endif
  else
    let url = root . '?ref=c-' . commit
  endif
  return url
endfunction

function! s:function(name) abort
  return function(substitute(a:name,'^s:',matchstr(expand('<sfile>'), '<SNR>\d\+_'),''))
endfunction

let g:fugitive_browse_handlers = [s:function('s:beanstalk_url')]
