#!/bin/bash
# Test suite for CVS access at Savanah

# We need:
# - 4 logins: 2 project members, 1 non-member, plus anoncvs
# - 1 project

# Recommended scheme:
# - project: members = member1 + member2
# - another project: members = member3 (so he gets a unix account)
# The same public key is used in all the 3 accounts to allow
# password-less testing


PORT=2022
HOST=cvs.savannah.gnu.org
WD=/tmp/cvs-test-suite

PROJECT=testyeight
MEMBER1=Beuc
MEMBER2=Beuc2
NONMEMBER=beuc3

# -----

trap 'echo Exit status: $?' ERR

rm -rf $WD
mkdir $WD || exit 1
cd $WD

if [ $PORT != 22 ]; then
    echo '#!/bin/sh' > myssh
    echo 'ssh -p '$PORT' $*' >> myssh
    chmod 755 myssh
    export CVS_RSH="$WD/myssh"
fi

# Tests:

echo "- Add a top-level directory with anoncvs"
cvs -Q -d:ext:anoncvs@$HOST:/sources/$PROJECT co -d test .
cd test
dirname=anonadd$$$RANDOM
mkdir $dirname
cvs add $dirname
exit_status=$?
#if [ $exit_status = 0 ]; then
    echo "CHECK: the error message; adding a directory as anoncvs should fail."
#fi
cd $WD
rm -rf test

echo "- Commit from member1"
cvs -Q -d:ext:$MEMBER1@$HOST:/sources/$PROJECT co -d test .
cd test
module=groupcommit$$$RANDOM
mkdir $module
cvs -Q add $module
exit_status=$?
if [ $exit_status != 0 ]; then
    echo "ERROR: a project member cannot add a directory."
fi
touch $module/TEST
cvs -Q add $module/TEST
exit_status=$?
if [ $exit_status != 0 ]; then
    echo "ERROR: a project member cannot add file."
fi
cvs -Q commit -m 'test' $module
exit_status=$?
if [ $exit_status != 0 ]; then
    echo "ERROR: a project member cannot commit."
fi

echo "- Was the author name scrambled (uidXXX)?"
echo "# test" >> CVSROOT/loginfo
output=`cvs log -w$MEMBER1 $module/TEST | grep author`
if [ -z "$output" ]; then
    echo "ERROR: member name is scrambled in the final RCS file."
fi

echo "- member1 tries to commit in CVSROOT"
echo "# test" >> CVSROOT/loginfo
cvs -Q add CVSROOT/loginfo
cvs -Q commit -m 'added another test line' CVSROOT/loginfo
exit_status=$?
if [ $exit_status = 0 ]; then
    echo "ERROR: member can commit to CVSROOT."
fi

echo "- Another commit from member2"
cd $wd
rm -rf test
cvs -Q -d:ext:$MEMBER2@$HOST:/sources/$PROJECT co -d test $module
cd test
echo "one line" >> TEST
cvs -Q commit -m 'added a test line' TEST
exit_status=$?
if [ $exit_status != 0 ]; then
    echo "ERROR: a project member cannot commit in another member's module."
fi

echo "- Non-member tries to commit"
cd $wd
rm -rf test
cvs -Q -d:ext:$NONMEMBER@$HOST:/sources/$PROJECT co -d test $module
cd test
echo "another line from non-member" >> TEST
cvs -Q commit -m 'added another test line' TEST
exit_status=$?
if [ $exit_status = 0 ]; then
    echo "ERROR: non member can commit."
fi
