" Vim autoload file for checking and installing C3 tool updates (:C3Update)
" Language: C3

if exists("g:autoloaded_c3_update")
  finish
endif
let g:autoloaded_c3_update = 1

" Tools known to :C3Update. 'repo' is the GitHub repository whose latest release
" is compared against the installed binary. 'cmd' is the command used to find
" the installed binary; the check is skipped when the user has pointed it at a
" binary whose name does not match 'name' (a custom formatter or linter).
function! s:tools() abort
  return [
        \ {'name': 'c3c',   'repo': 'c3lang/c3c',      'cmd': 'c3c'},
        \ {'name': 'c3f',   'repo': 'konimarti/c3f',   'cmd': get(g:, 'c3_fmt_command', get(g:, 'c3_format_command', 'c3f'))},
        \ {'name': 'c3vet', 'repo': 'konimarti/c3vet', 'cmd': get(g:, 'c3_vet_command', 'c3vet')},
        \ ]
endfunction

" Completion for :C3Update
function! c3#update#Complete(arglead, cmdline, cursorpos) abort
  return filter(map(s:tools(), 'v:val.name'), 'v:val =~# "^" . a:arglead')
endfunction

" Extract the first MAJOR.MINOR.PATCH number from a string, or ''
function! s:parse_version(text) abort
  return matchstr(a:text, '\d\+\.\d\+\.\d\+')
endfunction

" Compare two MAJOR.MINOR.PATCH strings component-wise.
" Returns -1, 0 or 1. Missing components count as 0.
function! s:compare_versions(a, b) abort
  let l:pa = map(split(a:a, '\.'), 'str2nr(v:val)')
  let l:pb = map(split(a:b, '\.'), 'str2nr(v:val)')
  for l:i in range(max([len(l:pa), len(l:pb)]))
    let l:x = l:i < len(l:pa) ? l:pa[l:i] : 0
    let l:y = l:i < len(l:pb) ? l:pb[l:i] : 0
    if l:x != l:y
      return l:x > l:y ? 1 : -1
    endif
  endfor
  return 0
endfunction

" Installed version of a tool, or {'error': ...} when it cannot be read
function! s:installed_version(tool) abort
  let l:bin = split(a:tool.cmd)[0]
  if !executable(l:bin)
    return {'error': 'not installed'}
  endif
  if fnamemodify(l:bin, ':t') !=# a:tool.name
    return {'error': 'custom binary "' . l:bin . '", not checked'}
  endif
  let l:out = system(shellescape(l:bin) . ' --version 2>&1')
  let l:ver = s:parse_version(l:out)
  if empty(l:ver)
    return {'error': 'could not read version from ' . l:bin}
  endif
  return {'version': l:ver}
endfunction

" Latest release of a GitHub repository.
" Returns {'version': 'X.Y.Z', 'url': ..., 'assets': [{'name', 'url'}]} or {'error': ...}.
function! s:latest_release(repo) abort
  if !executable('curl')
    return {'error': 'curl is required to check for updates'}
  endif

  let l:api = 'https://api.github.com/repos/' . a:repo . '/releases/latest'
  let l:cmd = 'curl -sL --max-time 10 -w ' . shellescape("\n%{http_code}")
        \ . ' -H ' . shellescape('Accept: application/vnd.github+json')
        \ . ' -H ' . shellescape('User-Agent: c3.vim')
        \ . ' ' . shellescape(l:api) . ' 2>/dev/null'
  let l:raw = system(l:cmd)

  if empty(l:raw)
    return {'error': 'could not reach GitHub'}
  endif

  " The last line is the HTTP status, everything before it is the body
  let l:lines = split(l:raw, "\n")
  let l:status = str2nr(get(l:lines, -1, '0'))
  let l:body = join(l:lines[:-2], "\n")

  if l:status == 403 || l:status == 429
    return {'error': 'GitHub rate limit reached, try again later'}
  elseif l:status == 404
    return {'error': 'no releases found for ' . a:repo}
  elseif l:status == 0
    return {'error': 'could not reach GitHub'}
  elseif l:status != 200
    return {'error': 'GitHub returned HTTP ' . l:status}
  endif

  try
    let l:data = json_decode(l:body)
  catch
    return {'error': 'could not parse the GitHub response'}
  endtry

  let l:tag = get(l:data, 'tag_name', '')
  let l:ver = s:parse_version(l:tag)
  if empty(l:ver)
    return {'error': 'unrecognised release tag "' . l:tag . '"'}
  endif

  let l:assets = map(copy(get(l:data, 'assets', [])),
        \ '{"name": v:val.name, "url": v:val.browser_download_url}')
  return {
        \ 'version': l:ver,
        \ 'url': get(l:data, 'html_url', 'https://github.com/' . a:repo . '/releases'),
        \ 'assets': l:assets,
        \ }
endfunction

" Release asset to download for a tool on this platform, or ''
function! s:asset_name(tool_name) abort
  let l:uname = substitute(system('uname -sm'), '\n', '', 'g')
  if l:uname =~# '^Linux x86_64$'
    let l:names = {'c3c': 'c3-linux.tar.gz', 'c3f': 'c3f-linux-x64.tar.gz', 'c3vet': 'c3vet-linux-x64.tar.gz'}
  elseif l:uname =~# '^Darwin arm64$'
    let l:names = {'c3c': 'c3-macos.zip', 'c3f': 'c3f-macos-aarch64.tar.gz', 'c3vet': 'c3vet-macos-aarch64.tar.gz'}
  else
    return ''
  endif
  return get(l:names, a:tool_name, '')
endfunction

" Lowercase SHA-256 of a file, or '' when no tool is available
function! s:sha256(path) abort
  if executable('sha256sum')
    let l:out = system('sha256sum ' . shellescape(a:path))
  elseif executable('shasum')
    let l:out = system('shasum -a 256 ' . shellescape(a:path))
  else
    return ''
  endif
  return matchstr(l:out, '^\x\{64}')
endfunction

function! s:download(url, dest) abort
  call system('curl -fsSL --max-time 300 -o ' . shellescape(a:dest) . ' ' . shellescape(a:url) . ' 2>/dev/null')
  return v:shell_error == 0 && filereadable(a:dest)
endfunction

" Download and install the latest release of an outdated tool over its existing
" binary. Returns {'message': ...} or {'error': ...}. The existing binary is kept
" as <path>.bak, and the new one is only put in place after it reports the
" expected version.
function! s:install(tool, latest) abort
  let l:asset_name = s:asset_name(a:tool.name)
  if empty(l:asset_name)
    return {'error': 'no release build for this platform, see ' . a:latest.url}
  endif

  let l:asset = filter(copy(a:latest.assets), 'v:val.name ==# l:asset_name')
  if empty(l:asset)
    return {'error': 'release v' . a:latest.version . ' has no ' . l:asset_name}
  endif

  " Refuse to replace symlinks: a dev build may be linked to a file outside PATH
  let l:target = exepath(split(a:tool.cmd)[0])
  if empty(l:target)
    return {'error': 'not installed'}
  endif
  if resolve(l:target) !=# l:target
    return {'error': l:target . ' is a symlink to ' . resolve(l:target) . ', not replaced; update it manually'}
  endif

  let l:dir = tempname()
  call mkdir(l:dir, 'p')
  try
    let l:file = l:dir . '/' . l:asset_name
    if !s:download(l:asset[0].url, l:file)
      return {'error': 'download failed: ' . l:asset[0].url}
    endif

    " Verify against SHA256SUMS when the release publishes one
    let l:verified = 0
    let l:sums = filter(copy(a:latest.assets), 'v:val.name ==# "SHA256SUMS"')
    if !empty(l:sums)
      let l:sumfile = l:dir . '/SHA256SUMS'
      if !s:download(l:sums[0].url, l:sumfile)
        return {'error': 'could not download SHA256SUMS'}
      endif
      let l:expected = ''
      for l:line in readfile(l:sumfile)
        let l:parts = split(l:line)
        if len(l:parts) == 2 && substitute(l:parts[1], '^\*', '', '') ==# l:asset_name
          let l:expected = l:parts[0]
        endif
      endfor
      if empty(l:expected)
        return {'error': 'SHA256SUMS has no entry for ' . l:asset_name}
      endif
      let l:actual = s:sha256(l:file)
      if empty(l:actual)
        return {'error': 'no sha256sum or shasum to verify the download'}
      endif
      if l:actual !=# l:expected
        return {'error': 'checksum mismatch for ' . l:asset_name . ', nothing installed'}
      endif
      let l:verified = 1
    endif

    " Unpack
    let l:extract = l:dir . '/out'
    call mkdir(l:extract, 'p')
    if l:asset_name =~# '\.zip$'
      call system('unzip -q -o ' . shellescape(l:file) . ' -d ' . shellescape(l:extract))
    else
      call system('tar -xzf ' . shellescape(l:file) . ' -C ' . shellescape(l:extract))
    endif
    if v:shell_error != 0
      return {'error': 'could not unpack ' . l:asset_name}
    endif

    let l:found = filter(globpath(l:extract, '**/' . a:tool.name, 0, 1), 'filereadable(v:val)')
    if empty(l:found)
      return {'error': a:tool.name . ' not found in ' . l:asset_name}
    endif
    let l:new = l:found[0]
    call setfperm(l:new, 'rwxr-xr-x')

    " The new binary must report the version we expected
    let l:ver = s:parse_version(system(shellescape(l:new) . ' --version 2>&1'))
    if l:ver !=# a:latest.version
      return {'error': 'downloaded binary reports "' . l:ver . '", expected ' . a:latest.version . ', nothing installed'}
    endif

    " Stage next to the target, then swap: the old binary is kept as .bak
    let l:staged = l:target . '.new'
    let l:backup = l:target . '.bak'
    call system('cp -f ' . shellescape(l:new) . ' ' . shellescape(l:staged))
    if v:shell_error != 0
      return {'error': 'could not write to ' . fnamemodify(l:target, ':h')}
    endif
    call setfperm(l:staged, 'rwxr-xr-x')
    if rename(l:target, l:backup) != 0
      call delete(l:staged)
      return {'error': 'could not move the old ' . l:target . ' aside'}
    endif
    if rename(l:staged, l:target) != 0
      call rename(l:backup, l:target)
      call delete(l:staged)
      return {'error': 'could not put the new binary in place, old one restored'}
    endif

    return {'message': l:target . ' updated to v' . l:ver
          \ . (l:verified ? ' (checksum verified)' : ' (no checksum published, not verified)')
          \ . '; old binary kept as ' . l:backup}
  finally
    call delete(l:dir, 'rf')
  endtry
endfunction

" Check one tool. Returns a dict:
"   status: 'up-to-date', 'outdated', 'ahead', 'missing', 'error'
"   message: a report line
"   installed, latest: versions (when known)
function! s:check_tool(tool) abort
  let l:installed = s:installed_version(a:tool)
  if has_key(l:installed, 'error') && l:installed.error =~# '^custom'
    return {'status': 'error', 'message': a:tool.name . ': ' . l:installed.error}
  endif

  let l:latest = s:latest_release(a:tool.repo)
  if has_key(l:latest, 'error')
    return {'status': 'error', 'message': a:tool.name . ': ' . l:latest.error}
  endif

  if has_key(l:installed, 'error')
    return {'status': 'missing', 'latest': l:latest,
          \ 'message': a:tool.name . ': ' . l:installed.error . ' (latest v' . l:latest.version . ': ' . l:latest.url . ')'}
  endif

  let l:cmp = s:compare_versions(l:installed.version, l:latest.version)
  if l:cmp < 0
    return {'status': 'outdated', 'installed': l:installed.version, 'latest': l:latest,
          \ 'message': a:tool.name . ': ' . l:installed.version . ' installed, v' . l:latest.version
          \ . ' available: ' . l:latest.url}
  elseif l:cmp > 0
    return {'status': 'ahead', 'installed': l:installed.version, 'latest': l:latest,
          \ 'message': a:tool.name . ': ' . l:installed.version . ' (newer than latest release v' . l:latest.version . ')'}
  endif
  return {'status': 'up-to-date', 'installed': l:installed.version, 'latest': l:latest,
        \ 'message': a:tool.name . ': ' . l:installed.version . ' (up to date)'}
endfunction

" :C3Update[!] [tool ...] checks c3c, c3f and c3vet for newer GitHub releases.
" With !, outdated tools that are already installed are replaced by the latest release.
function! c3#update#Update(args, bang) abort
  let l:all = s:tools()
  let l:names = split(a:args)
  let l:tools = []

  if empty(l:names)
    let l:tools = l:all
  else
    for l:name in l:names
      let l:match = filter(copy(l:all), 'v:val.name ==# tolower(l:name)')
      if empty(l:match)
        echohl ErrorMsg
        echomsg 'c3.vim: unknown tool "' . l:name . '" (expected: ' . join(map(copy(l:all), 'v:val.name'), ', ') . ')'
        echohl None
        return
      endif
      call add(l:tools, l:match[0])
    endfor
  endif

  if !executable('curl')
    echohl ErrorMsg
    echomsg 'c3.vim: curl is required to check for updates'
    echohl None
    return
  endif

  echomsg 'c3.vim: checking for updates...'
  redraw

  let l:lines = []
  for l:tool in l:tools
    let l:result = s:check_tool(l:tool)
    let l:line = l:result.message

    if l:result.status ==# 'outdated'
      if a:bang
        let l:inst = s:install(l:tool, l:result.latest)
        let l:line = has_key(l:inst, 'error')
              \ ? l:tool.name . ': update failed: ' . l:inst.error
              \ : l:tool.name . ': ' . l:inst.message
      else
        let l:line .= ' (run :C3Update! to install)'
      endif
    endif

    call add(l:lines, '  ' . l:line)
  endfor

  echo join(['c3.vim: update check'] + l:lines, "\n")
endfunction
