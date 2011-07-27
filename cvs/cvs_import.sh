#!/bin/sh

# A few heuristics to automagically import a CVS repository

# Ok, functions are not a truly portable construct...
function usage() {
    echo "Usage: $0 URL project_name [web]"
    exit 1
}

url=$1
project=$2
repo_type=$3
if [ -z "$url" -o -z "$project" ]; then
    usage
fi
if [ -n "$repo_type" -a x"$repo_type" != x"web" ]; then
    usage
fi
if getent group $project > /dev/null; then :; else
    echo "$project isn't a Unix group."
    exit 1
fi
if [ x"$repo_type" = x"web"  ]; then
    repo_type=web
    unix_group=web$project
else
    repo_type=sources
    unix_group=$project
fi


wd=working_dir$$
rm -rf $wd
mkdir $wd || exit 1
cd $wd

if ! wget --quiet "$url"; then
    echo "Cannot download $url"
    exit 1
fi
file=`ls`
case $file in
*.tar.gz|*.tgz)
	tar xzf $file || exit 1
	;;
*.tar.bz2|*.tbz)
	tar xjf $file || exit 1
	;;
*)
	tar xzf $file || exit 1
#	echo "Unknown extension for file $file - stopping."
#	exit 1
	;;
esac
rm -f $file

if [ `ls | wc -l` -eq 1 ]; then
    module=`ls`
    cd $module
else
# all in the current folder - ugh
:
fi

if [ -z "`find -name '*,v' -type f`" ]; then
    echo "No ,v files, it must a checkout instead of an actual repository."
    exit 1
fi

chown -R root:$unix_group .
find -type d -print0 | xargs -0 chmod 2775
find -type f -print0 | xargs -0 chmod a=rX
find -type f -path '*/CVS/fileattr' -print0 | xargs -0 --no-run-if-empty chmod 664

repo_path=/$repo_type/$project
if [ -d CVSROOT ]; then
    # top-level CVS repository
    cat CVSROOT/val-tags $repo_path/CVSROOT/val-tags | sort | uniq > CVSROOT/val-tags2
    cat CVSROOT/val-tags2 > $repo_path/CVSROOT/val-tags
    cat CVSROOT/history >> $repo_path/CVSROOT/history
    chmod 666 $repo_path/CVSROOT/history
    rm -rf CVSROOT
fi

cur_files=`find -maxdepth 1 -type f`
if [ -z "$cur_files" ]; then
    # only modules - prune empty destination dirs
    modules=`find -mindepth 1 -maxdepth 1 -type d`
else
    # inside a module
    if [ -n "$module" ]; then
	:
    elif [ -z `ls $repo_path/$project` ]; then
	module=$project
    else
	echo Enter the destination module name:
	read module
    fi
    modules="$module"
fi

for i in $modules; do
    rmdir $repo_path/$i 2> /dev/null
    if [ -e $repo_path/$i ]; then
	echo "$repo_path/$i already exist"
	exit
    fi
done

if [ -n "$module" ]; then
    dest=$repo_path/$module
    mkdir -m 2775 $dest
    chown root:$unix_group $dest
else
    dest=$repo_path
fi

# Takes care of dot files and keeps permission
# $module can be empty
find -maxdepth 1 -mindepth 1 -print0 | xargs -0 -n1 -I{} mv {} $dest

echo "Repository imported to $dest:"
ls -lAh $dest

while [ ! -e $wd -o x`pwd` = x"/" ]; do
    cd ..
done
rm -rf $wd
