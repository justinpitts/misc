#!/bin/bash

svn-conflicts()
{
    svn status | grep ^C | cut -c 8-
}

svn-externals()
{
    svn status | grep ^X | cut -c 8-
}

svn-ignored()
{
    svn status --no-ignore | grep ^I | cut -c 8-
}

svn-revirginize()
{
    svn-ignored | while read f; do rm -r “$f“ ; done
}

svn-unknown()
{
    svn status | grep ^? | cut -c 8-
}


svnpurge ()
{
    svn status | grep ^! | cut -c 8- | while read f ; do svn rm “$f“ ; done
}

sfind ()
{
    if [ $# -eq 0 ] ; then
	find
    else
	local path=$1
	shift

	if [ $# -eq 0 ] ; then
	    find $path -path '*/.svn' -prune -o -print
	else
	    local gotCmd
	    local arg

	    for arg in $@; do
		case $arg in
		    -exec | -ls | -ok | -print | -print0)
			gotCmd=yes
			;;
		    *)
			;;
		esac
	    done

	    if [ -z $gotCmd ] ; then
# No commands -- implicit print
		find $path -path '*/.svn' -prune -o $* -print
	    else
		find $path -path '*/.svn' -prune -o $*
	    fi
	fi
    fi
}

rgrep ()
{
    local arg
    local args
    local pattern
    local switches

    for arg in “$@“; do
	case $arg in
	    -i | -l | -il)
		switches=“$switches $arg“
		;;
	    *)
		if [ “x$pattern“ = x ]; then
		    pattern=$arg
		else
		    args=“$args $arg“
		fi
		;;
	esac
    done

    if [ “x$args“ = x ]; then
	args=.
    fi

    for arg in $args; do
	find $arg -path '*/.svn' -prune -o -name '*~' -prune -o -type f -print | while read f ; do grep --with-filename $switches “$pattern“ “$f“ ; done
    done
}