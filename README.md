# vim-codenarc
CodeNarc integration for vim.

# Syntastic
Primitive but usable. Derived from the CheckStyle checker from the Syntastic distribution.
Requires [syntastic](https://github.com/scrooloose/syntastic.git)

In my .vimrc:

    let g:syntastic_groovy_checkers=['codenarc']
    let g:syntastic_groovy_codenarc_rulesets = 'rulesets/basic.xml,rulesets/imports.xml'

`g:syntastic_groovy_codenarc_rulesets` defaults to rulesets/basic.xml

`g:syntastic_groovy_codenarc_classpath` should contain everything for the CodeNarc cli.
Defaults to all the jars in the lib directory in this project.

#TODO

* Figure out if there are any licensing issues w.r.t. the included jars.
* Add another config/global to allow for adding to the classpath, to allow for using the enhanced.xml ruleset.
* Add a compiler plugin/errorformat to allow for bulk correction.
