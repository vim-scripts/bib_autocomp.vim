" File:        bib_autocomp.vim
" Brief:       Autocompletion of BibTeX entries
" Author:      Petr Zemek, s3rvac AT gmail DOT com
" Version:     1.0.1
" Last Change: Sat Aug 15 22:14:36 CEST 2009
"
" License:
"   Copyright (C) 2009 Petr Zemek
"   This program is free software; you can redistribute it and/or modify it
"   under the terms of the GNU General Public License as published by the Free
"   Software Foundation; either version 2 of the License, or (at your option)
"   any later version.
"
"   This program is distributed in the hope that it will be useful, but
"   WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
"   or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
"   for more details.
"
"   You should have received a copy of the GNU General Public License along
"   with this program; if not, write to the Free Software Foundation, Inc.,
"   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
"
" Description:
"   Note: When I wrote this plugin I didn't know about the snipMate plugin
"         (http://www.vim.org/scripts/script.php?script_id=2540). It offers
"         much more features than this plugin, but you have to create your
"         own snippets for *.bib files (there are no default one for
"         the BibTeX filetype). You are encouraged to check it out before
"         you start using this plugin.
"
"   This filetype plugin does autocompletion of BibTeX entries in *.bib files.
"   When you type the beginning of a BibTeX entry (e.g. @article{), it will
"   try to complete it. The completed result might then look like this
"   (see configuration options for customization):
"     @article{<cursor position>,
"	      author = {},
"         title = {},
"         journal = {},
"         year = {}
"     }
"
"   Configuration options for this plugin (you can set them in your $HOME/.vimrc):
"    - g:bib_autocomp_enable (0 or 1, default 1)
"        Enables/disables this plugin.
"    - g:bib_autocomp_tag_indent (string, default "\<Tab>")
"        Indention of tags inside a BibTeX entry. So for example, if you want
"        each tag to be indented by four spaces, set this to "    ". Or if
"        you want to indent by two tabs, set this to "\<Tab>\<Tab>".
"    - g:bib_autocomp_tag_content_enclosing (string, default '{}')
"        Enclosing of a tag content. If you prefer quotes to curly brackets,
"        set this to '""' (the tag will then look like this: author = "").
"    - g:bib_autocomp_trim_last_comma (0 or 1, default 1)
"        When set to 1, it will omit the last comma in the tag list (so
"        the result will look as the @article one in the previous paragraph).
"        If you want to keep the comma after the last tag, set this to 0.
"    - g:bib_autocomp_special_entries (list of strings, default ['string',
"        'preamble', 'comment'])
"        List of entries, which are considered "special". A special entry
"        is not a type of a publication, so these entries will be completed
"        just with the enclosing curly brackets, e.g. @comment{}
"        (see http://www.bibtex.org/Format/ for more info).
"    - g:bib_autocomp_entry_mapping (dictionary, read on for info)
"        This dictionary defines a mapping between a BibTeX entry name
"        and the list of tags it should contain. It is by default initialized
"        to all standard entries (see http://en.wikipedia.org/wiki/Bibtex)
"        and all required tags for each entry are inserted.
"        If you want to add some entry or change the list of tags, set the
"        configuration variable in your configuration file as follows:
"          let g:bib_autocomp_entry_mapping = {
"            \ 'entry-name': ['first-tag', 'second-tag', ...]
"            \ }
"        So for example, if you want to change the list of tags for the
"        @misc entry, set the variable in this fashion:
"          let g:bib_autocomp_entry_mapping = {
"            \ 'misc': ['author', 'title', 'howpublished', 'url']
"            \ }
"        If you also want to add some custom entry, then use this template:
"          let g:bib_autocomp_entry_mapping = {
"            \ 'misc': ['author', 'title', 'howpublished', 'url'],
"            \ 'custom': ['author', 'title', 'url']
"            \ }
"        As you can see, it is just a dictionary written in the Vimscript
"        language.
"
" Requirements:
"   - filetype plugin must be enabled (a line like 'filetype plugin on' must
"     be in your $HOME/.vimrc [*nix] or %UserProfile%\_vimrc [MS Windows])
"
" Installation Details:
"   Put this file into your $HOME/.vim/ftplugin directory [*nix]
"   or %UserProfile%\vimfiles\ftplugin folder [MS Windows].
"
" Notes:
"  This script is by all means NOT perfect, but it works for me and suits my
"  needs very well, so it might be also useful for you. Your feedback,
"  opinion, suggestions, bug reports, patches, simply anything you have
"  to say is welcomed!
"
" Changelog:
"   1.0.1 (2009-08-15)
"     - Documentation changes.
"   1.0 (2009-08-11)
"     - Initial release version of this script.
"

" Check if the plugin was already loaded
if exists('b:bib_autocomp_loaded')
	finish
endif
let b:bib_autocomp_loaded = 1

"-------------------------------------------------------------------------------
" Checks whether the selected variable (first parameter) is already set and
" if not, it sets it to the value of the second parameter.
"-------------------------------------------------------------------------------
function s:CheckAndSetVar(var, value)
	if !exists(a:var)
		exec 'let ' . a:var . ' = ' . string(a:value)
	endif
endfunction

" Configuration variables initialization
" (see script description for more information)
call s:CheckAndSetVar('g:bib_autocomp_enable', 1)
call s:CheckAndSetVar('g:bib_autocomp_tag_indent', "\<Tab>")
call s:CheckAndSetVar('g:bib_autocomp_tag_content_enclosing', '{}')
call s:CheckAndSetVar('g:bib_autocomp_trim_last_comma', 1)
call s:CheckAndSetVar('g:bib_autocomp_special_entries', ['string', 'preamble', 'comment'])
call s:CheckAndSetVar('g:bib_autocomp_entry_mapping', {})

" Default mapping between a BibTeX entry and its tags (only required tags
" are used by default, see http://en.wikipedia.org/wiki/BibTeX for more info)
let s:default_entry_mapping = {}
let s:default_entry_mapping['article'] = ['author', 'title', 'journal', 'year']
let s:default_entry_mapping['book'] = ['author', 'title', 'publisher', 'year']
let s:default_entry_mapping['booklet'] = ['title']
let s:default_entry_mapping['conference'] = ['author', 'title', 'booktitle', 'year']
let s:default_entry_mapping['inbook'] = ['author', 'title', 'pages', 'publisher', 'year']
let s:default_entry_mapping['incollection'] = ['author', 'title', 'booktitle', 'year']
let s:default_entry_mapping['inproceedings'] = ['author', 'title', 'booktitle', 'year']
let s:default_entry_mapping['manual'] = ['title']
let s:default_entry_mapping['mastersthesis'] = ['author', 'title', 'school', 'year']
let s:default_entry_mapping['misc'] = []
let s:default_entry_mapping['phdthesis'] = ['author', 'title', 'school', 'year']
let s:default_entry_mapping['proceedings'] = ['title', 'year']
let s:default_entry_mapping['techreport'] = ['author', 'title', 'institution', 'year']
let s:default_entry_mapping['unpublished'] = ['author', 'title', 'note']

" Initialize the mapping between BibTeX entry and its tags (this is done
" because it is possible for the user to change some of these mappings)
for entry_name in keys(s:default_entry_mapping)
	if !has_key(g:bib_autocomp_entry_mapping, entry_name)
		let g:bib_autocomp_entry_mapping[entry_name] =
			\ s:default_entry_mapping[entry_name]
	endif
endfor

"-------------------------------------------------------------------------------
" Checks whether the selected text is a valid BibTeX entry and if so, it
" returns the name of the entry (all lower case). Otherwise, it returns
" the empty string.
"-------------------------------------------------------------------------------
function s:IsBibTeXEntry(text)
	let entry_start_re = '^\s*@'

	" First check whether the entry could possibly be a BibTeX entry
	if a:text =~ entry_start_re . '[a-zA-Z]\+$'
		" It could, so try to first match it against special entry names
		for entry_name in g:bib_autocomp_special_entries
			if a:text =~? entry_start_re . entry_name
				" We found a match
				return tolower(entry_name)
			endif
		endfor

		" It is not a special entry name, so check the ordinary entry names
		for entry_name in keys(g:bib_autocomp_entry_mapping)
			if a:text =~? entry_start_re . entry_name
				" We found a match
				return tolower(entry_name)
			endif
		endfor

		" It is not even an ordinary entry name, so just return it
		return tolower(substitute(a:text, entry_start_re, '', ''))
	else
		" The selected text could not be a BibTeX entry
		return ''
	endif
endfunction

"-------------------------------------------------------------------------------
" Checks whether the user started a BibTeX entry and if so, it tries
" to complete it. Returns an action to be performed.
"
" Note: This function must be called right after the '{' character is inserted!
"-------------------------------------------------------------------------------
function <SID>TryCompleteBibtexEntry()
	let entry_name = s:IsBibTeXEntry(getline('.'))
	if entry_name == ''
		" It is not an entry name, so just insert the '{' character
		return 'normal! a{'
	endif

	" Is it a special entry?
	if index(g:bib_autocomp_special_entries, entry_name) >= 0
		" Because it is a special entry name, return just the enclosing brackets
		return 'normal! a{}'
	endif

	" It must be an ordinary entry, so:
	" 1) Create the tag list for this entry
	let tag_list = ''
	" The entry name exists (there is a mapping for it), so check
	" the list of tags for it
	for tag_name in get(g:bib_autocomp_entry_mapping, entry_name, [])
		let tag_list .= g:bib_autocomp_tag_indent .
			\ tag_name . ' = ' . g:bib_autocomp_tag_content_enclosing .
			\ ",\<CR>"
	endfor

	" 2) Remove the last comma from the tag list if the user wish that
	if g:bib_autocomp_trim_last_comma
		let tag_list = substitute(tag_list, ",\<CR>$", "\<CR>", '')
	endif

	" 3) Insert the tag list into curly brackets and complete the entry
	let comp_bibtex_entry = "{,\<CR>" . tag_list . '}'

	" 4) Return action that will complete the BibTeX entry
	return 'normal a' . comp_bibtex_entry . "\<Esc>%"
endfunction

" When the user types {, check whether it is a beginning of a BibTeX entry
" and if so, try to complete it
if g:bib_autocomp_enable
	inoremap <silent> <buffer> {
		\ <Esc>:set paste<CR>:exec <SID>TryCompleteBibtexEntry()<CR>:set nopaste<CR>a
endif
