From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 16 Mar 2012 12:59:44 -0000
Subject: LVM2/test/lib check.sh get.sh test.sh utils.sh
Message-ID: <20120316125944.23364.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-16 12:59:43

Modified files:
	test/lib       : check.sh get.sh test.sh utils.sh 

Log message:
	Update test.sh check.sh utils.sh get.sh
	
	Indent
	Better shell usage
	Function simplification
	More usage of 'get' functions
	Don't use valgrind tracing for check and get function (faster)
	Update shell debugging (PS4, better stacktrace)
	Support paths with spaces
	Export SCRIPTNAME for external usage
	Watch for dmeventd unexpectedly started during test

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/check.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/get.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/test.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/utils.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/test/lib/check.sh	2011/09/09 13:19:19	1.6
+++ LVM2/test/lib/check.sh	2012/03/16 12:59:43	1.7
@@ -1,6 +1,5 @@
 #!/bin/bash
-
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2010-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -12,7 +11,7 @@
 
 # check.sh: assert various things about volumes
 
-# USAGE
+# USAGE:
 #  check linear VG LV
 #  check lv_on VG LV PV
 
@@ -23,14 +22,11 @@
 
 # ...
 
-set -e -o pipefail
-
-trim()
-{
-    trimmed=${1%% }
-    trimmed=${trimmed## }
+test -z "$BASH" || set -e -o pipefail
 
-    echo "$trimmed"
+die() {
+	echo "$@" >&2
+	return 1
 }
 
 lvl() {
@@ -38,258 +34,206 @@
 }
 
 lvdevices() {
-	lvl -odevices "$@" | sed 's/([^)]*)//g; s/,/ /g'
+	get lv_devices "$@"
 }
 
-mirror_images_redundant()
-{
-  vg=$1
-  lv=$vg/$2
-
-  lvs -a $vg -o+devices
-  for i in `lvdevices $lv`; do
-	  echo "# $i:"
-	  lvdevices $vg/$i | sort | uniq
-  done > check.tmp.all
-
-  (grep -v ^# check.tmp.all || true) | sort | uniq -d > check.tmp
-
-  test "`cat check.tmp | wc -l`" -eq 0 || {
-	  echo "mirror images of $lv expected redundant, but are not:"
-	  cat check.tmp.all
-	  exit 1
-  }
+mirror_images_redundant() {
+	local vg=$1
+	local lv=$vg/$2
+	lvs -a $vg -o+devices
+	for i in $(lvdevices $lv); do
+		echo "# $i:"
+		lvdevices $vg/$i | sort | uniq
+	done > check.tmp.all
+
+	(grep -v ^# check.tmp.all || true) | sort | uniq -d > check.tmp
+
+	test $(cat check.tmp | wc -l) -eq 0 || \
+		die "mirror images of $lv expected redundant, but are not:" \
+			$(cat check.tmp.all)
+}
+
+lv_on() {
+	local lv=$1/$2
+	(lvdevices $lv | grep -F "$3") || \
+		die "LV $lv expected on $3 but is not:" \
+			$(lvdevices $lv)
+	test $(lvdevices $lv | grep -vF "$3" | wc -l) -eq 0 || \
+		die "LV $lv contains unexpected devices:" \
+			$(lvdevices $lv)
 }
 
 mirror_images_on() {
-	vg=$1
-	lv=$2
-
+	local vg=$1
+	local lv=$2
 	shift 2
-
-	for i in `lvdevices $lv`; do
+	for i in $(lvdevices $lv); do
 		lv_on $vg $lv $1
 		shift
 	done
 }
 
-lv_on()
-{
-	lv="$1/$2"
-	lvdevices $lv | grep -F "$3" || {
-		echo "LV $lv expected on $3 but is not:" >&2
-		lvdevices $lv >&2
-		exit 1
-	}
-	test `lvdevices $lv | grep -vF "$3" | wc -l` -eq 0 || {
-		echo "LV $lv contains unexpected devices:" >&2
-		lvdevices $lv >&2
-		exit 1
-	}
-}
-
-mirror_log_on()
-{
-	vg="$1"
-	lv="$2"
-	where="$3"
+mirror_log_on() {
+	local vg=$1
+	local lv=$2
+	local where=$3
 	if test "$where" = "core"; then
-		lvl -omirror_log "$vg/$lv" | not grep mlog
+		get lv_field $vg/$lv mirror_log | not grep mlog
 	else
-		lv_on $vg "${lv}_mlog" "$where"
+		lv_on $vg ${lv}_mlog "$where"
 	fi
 }
 
-lv_is_contiguous()
-{
-	test `lvl --segments $1 | wc -l` -eq 1 || {
-		echo "LV $1 expected to be contiguous, but is not:"
-		lvl --segments $1
-		exit 1
-	}
-}
-
-lv_is_clung()
-{
-	test `lvdevices $1 | sort | uniq | wc -l` -eq 1 || {
-		echo "LV $1 expected to be clung, but is not:"
-		lvdevices $! | sort | uniq
-		exit 1
-	}
-}
-
-mirror_images_contiguous()
-{
-	for i in `lvdevices $1/$2`; do
-		lv_is_contiguous $1/$i
+lv_is_contiguous() {
+	local lv=$1/$2
+	test $(lvl --segments $lv | wc -l) -eq 1 || \
+		die "LV $lv expected to be contiguous, but is not:" \
+			$(lvl --segments $lv)
+}
+
+lv_is_clung() {
+	local lv=$1/$2
+	test $(lvdevices $lv | sort | uniq | wc -l) -eq 1 || \
+		die "LV $lv expected to be clung, but is not:" \
+			$(lvdevices $lv | sort | uniq)
+}
+
+mirror_images_contiguous() {
+	for i in $(lvdevices $1/$2); do
+		lv_is_contiguous $1 $i
 	done
 }
 
-mirror_images_clung()
-{
-	for i in `lvdevices $1/$2`; do
-		lv_is_clung $1/$i
+mirror_images_clung() {
+	for i in $(lvdevices $1/$2); do
+		lv_is_clung $1 $i
 	done
 }
 
 mirror() {
 	mirror_nonredundant "$@"
-	mirror_images_redundant "$1" "$2"
+	mirror_images_redundant $1 $2
 }
 
 mirror_nonredundant() {
-	lv="$1/$2"
-	lvs -oattr "$lv" | grep "^ *m.......$" >/dev/null || {
-		if lvs -oattr "$lv" | grep "^ *o.......$" >/dev/null &&
+	local lv=$1/$2
+	local attr=$(get lv_field $lv attr)
+	(echo "$attr" | grep "^m.......$" >/dev/null) || {
+		if (echo "$attr" | grep "^o.......$" >/dev/null) &&
 		   lvs -a | fgrep "[${2}_mimage" >/dev/null; then
 			echo "TEST WARNING: $lv is a snapshot origin and looks like a mirror,"
 			echo "assuming it is actually a mirror"
 		else
-			echo "$lv expected a mirror, but is not:"
-			lvs -a $lv
-			exit 1
+			die "$lv expected a mirror, but is not:" \
+				$(lvs $lv)
 		fi
 	}
-	if test -n "$3"; then mirror_log_on "$1" "$2" "$3"; fi
+	test -z "$3" || mirror_log_on $1 $2 "$3"
 }
 
 mirror_legs() {
-	lv="$1/$2"
-	expect="$3"
-	lvdevices "$lv"
-	real=`lvdevices "$lv" | wc -w`
-	test "$expect" = "$real"
+	local expect=$3
+	test "$expect" -eq $(lvdevices $1/$2 | wc -w)
 }
 
-mirror_no_temporaries()
-{
-	vg=$1
-	lv=$2
-	lvl -oname $vg | grep $lv | not grep "tmp" || {
-		echo "$lv has temporary mirror images unexpectedly:"
-		lvl $vg | grep $lv
-		exit 1
-	}
+mirror_no_temporaries() {
+	local vg=$1
+	local lv=$2
+	(lvl -o name $vg | grep $lv | not grep "tmp") || \
+		die "$lv has temporary mirror images unexpectedly:" \
+			$(lvl $vg | grep $lv)
 }
 
 linear() {
-	lv="$1/$2"
-	lvl -ostripes "$lv" | grep "1" >/dev/null || {
-		echo "$lv expected linear, but is not:"
-		lvl "$lv" -o+devices
-		exit 1
-	}
+	local lv=$1/$2
+	test $(get lv_field $lv stripes -a) -eq 1 || \
+		die "$lv expected linear, but is not:" \
+			$(lvl $lv -o+devices)
 }
 
 active() {
-	lv="$1/$2"
-	lvl -oattr "$lv" 2> /dev/null | grep "^ *....a...$" >/dev/null || {
-		echo "$lv expected active, but lvs says it's not:"
-		lvl "$lv" -o+devices 2>/dev/null
-		exit 1
-	}
-	dmsetup table | egrep "$1-$2: *[^ ]+" >/dev/null || {
-		echo "$lv expected active, lvs thinks it is but there are no mappings!"
-		dmsetup table | grep $1-$2:
-		exit 1
-	}
+	local lv=$1/$2
+	(get lv_field $lv attr $lv | grep "^....a...$" >/dev/null) || \
+		die "$lv expected active, but lvs says it's not:" \
+			$(lvl $lv -o+devices)
+	(dmsetup table | egrep "$1-$2: *[^ ]+" >/dev/null) || \
+		die "$lv expected active, lvs thinks it is but there are no mappings!" \
+			$(dmsetup table | grep $1-$2:)
 }
 
 inactive() {
-	lv="$1/$2"
-	lvl -oattr "$lv" 2> /dev/null | grep '^ *....[-isd]...$' >/dev/null || {
-		echo "$lv expected inactive, but lvs says it's not:"
-		lvl "$lv" -o+devices 2>/dev/null
-		exit 1
-	}
-	dmsetup table | not egrep "$1-$2: *[^ ]+" >/dev/null || {
-		echo "$lv expected inactive, lvs thinks it is but there are mappings!"
-		dmsetup table | grep $1-$2:
-		exit 1
-	}
+	local lv=$1/$2
+	(get lv_field $lv attr | grep "^....[-isd]...$" >/dev/null) || \
+		die "$lv expected inactive, but lvs says it's not:" \
+			$(lvl $lv -o+devices)
+	(dmsetup table | not egrep "$1-$2: *[^ ]+" >/dev/null) || \
+		die "$lv expected inactive, lvs thinks it is but there are mappings!" \
+			$(dmsetup table | grep $1-$2:)
 }
 
+# Check for list of LVs from given VG
 lv_exists() {
-	lv="$1/$2"
-	lvl "$lv" >& /dev/null || {
-		echo "$lv expected to exist but does not"
-		exit 1
-	}
+	local vg=$1
+	local lv=
+	while [ $# -gt 1 ]; do
+		shift
+		lv="$lv $vg/$1"
+	done
+	lvl $lv &>/dev/null || \
+		die "$lv expected to exist but does not"
+}
+
+pv_field() {
+	local actual=$(get pv_field "$1" "$2" "${@:4}")
+	test "$actual" = "$3" || \
+		die "pv_field: PV=\"$1\", field=\"$2\", actual=\"$actual\", expected=\"$3\""
 }
 
-pv_field()
-{
-    actual=$(trim $(pvs --noheadings $4 -o $2 $1))
-
-    test "$actual" = "$3" || {
-        echo "pv_field: PV=$1, field=$2, actual=$actual, expected=$3"
-        exit 1
-    }
-}
-
-vg_field()
-{
-    actual=$(trim $(vgs --noheadings $4 -o $2 $1))
-    test "$actual" = "$3" || {
-        echo "vg_field: vg=$1, field=$2, actual=$actual, expected=$3"
-        exit 1
-    }
-}
-
-lv_field()
-{
-    actual=$(trim $(lvs --noheadings $4 -o $2 $1))
-    test "$actual" = "$3" || {
-        echo "lv_field: lv=$1, field=$2, actual=$actual, expected=$3"
-        exit 1
-    }
-}
-
-compare_fields()
-{
-    local cmd1=$1;
-    local obj1=$2;
-    local field1=$3;
-    local cmd2=$4;
-    local obj2=$5;
-    local field2=$6;
-    local val1;
-    local val2;
-
-    val1=$($cmd1 --noheadings -o $field1 $obj1)
-    val2=$($cmd2 --noheadings -o $field2 $obj2)
-    test "$val1" = "$val2" || {
-        echo "compare_fields $obj1($field1): $val1 $obj2($field2): $val2"
-        exit 1
-    }
-}
-
-compare_vg_field()
-{
-    local vg1=$1;
-    local vg2=$2;
-    local field=$3;
-
-    val1=$(vgs --noheadings -o $field $vg1)
-    val2=$(vgs --noheadings -o $field $vg2)
-    test "$val1" = "$val2" || {
-        echo "compare_vg_field: $vg1: $val1, $vg2: $val2"
-        exit 1
-    }
+vg_field() {
+	local actual=$(get vg_field $1 "$2" "${@:4}")
+	test "$actual" = "$3" || \
+		die "vg_field: vg=$1, field=\"$2\", actual=\"$actual\", expected=\"$3\""
 }
 
-pvlv_counts()
-{
+lv_field() {
+	local actual=$(get lv_field $1 "$2" "${@:4}")
+	test "$actual" = "$3" || \
+		die "lv_field: lv=$lv, field=\"$2\", actual=\"$actual\", expected=\"$3\""
+}
+
+compare_fields() {
+	local cmd1=$1
+	local obj1=$2
+	local field1=$3
+	local cmd2=$4
+	local obj2=$5
+	local field2=$6
+	local val1=$($cmd1 --noheadings -o "$field1" "$obj1")
+	local val2=$($cmd2 --noheadings -o "$field2" "$obj2")
+	test "$val1" = "$val2" || \
+		die "compare_fields $obj1($field1): $val1 $obj2($field2): $val2"
+}
+
+compare_vg_field() {
+	local vg1=$1
+	local vg2=$2
+	local field=$3
+	local val1=$(vgs --noheadings -o "$field" $vg1)
+	local val2=$(vgs --noheadings -o "$field" $vg2)
+	test "$val1" = "$val2" || \
+		die "compare_vg_field: $vg1: $val1, $vg2: $val2"
+}
+
+pvlv_counts() {
 	local local_vg=$1
 	local num_pvs=$2
 	local num_lvs=$3
 	local num_snaps=$4
-
-	lvs -a -o+devices $local_vg
-
+	lvs -o+devices $local_vg
 	vg_field $local_vg pv_count $num_pvs
 	vg_field $local_vg lv_count $num_lvs
 	vg_field $local_vg snap_count $num_snaps
 }
 
+unset LVM_VALGRIND
 "$@"
--- LVM2/test/lib/get.sh	2011/01/05 00:16:21	1.1
+++ LVM2/test/lib/get.sh	2012/03/16 12:59:43	1.2
@@ -1,4 +1,5 @@
-# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#!/bin/sh
+# Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -8,16 +9,37 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+# get.sh: get various values from volumes
+#
+# USAGE:
+#  get pv_field PV field [pvs params]
+#  get vg_field VG field [vgs params]
+#  get lv_field LV field [lvs params]
+#
+#  get lv_devices LV     [lvs params]
+
+
+# trims only leading prefix, we should not need trim trailing spaces
+trim_() {
+	#local var=${var%"${var##*[! ]}"}  # remove trailing space characters
+	echo ${1#"${1%%[! ]*}"} # remove leading space characters
+}
+
 pv_field() {
-	pvs --noheading -o $2 $1 | sed 's/^ *//'
+	trim_ "$(pvs --noheadings -o $2 ${@:3} $1)"
 }
 
 vg_field() {
-	vgs --noheading -o $2 $1 | sed 's/^ *//'
+	trim_ "$(vgs --noheadings -o $2 ${@:3} $1)"
 }
 
 lv_field() {
-	lvs --noheading -o $2 $1 | sed 's/^ *//'
+	trim_ "$(lvs --noheadings -o $2 ${@:3} $1)"
+}
+
+lv_devices() {
+	lv_field $1 devices -a "${@:2}" | sed 's/([^)]*)//g; s/,/ /g'
 }
 
+unset LVM_VALGRIND
 "$@"
--- LVM2/test/lib/test.sh	2012/02/15 14:24:32	1.8
+++ LVM2/test/lib/test.sh	2012/03/16 12:59:43	1.9
@@ -1,3 +1,4 @@
+#!/bin/bash
 # Copyright (C) 2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -13,55 +14,63 @@
 LC_ALL=C
 TZ=UTC
 
+# Put script name into variable, so it can used in external scripts
+TESTNAME=${0##*/}
+# Nice debug message
+PS4=' ${BASH_SOURCE[0]##*/}:${LINENO}+ '
+export TESTNAME PS4
+
 unset CDPATH
 
 # grab some common utilities
 . lib/utils
 
-OLDPWD="`pwd`"
+TESTOLDPWD=$(pwd)
 COMMON_PREFIX="LVMTEST"
 PREFIX="${COMMON_PREFIX}$$"
 
-TESTDIR=$(mkdtemp ${LVM_TEST_DIR-$(pwd)} $PREFIX.XXXXXXXXXX) \
-	|| { echo "failed to create temporary directory in ${LVM_TEST_DIR-$(pwd)}"; exit 1; }
+TESTDIR=$(mkdtemp "${LVM_TEST_DIR-$TESTOLDPWD}" "$PREFIX.XXXXXXXXXX") || \
+	die "failed to create temporary directory in ${LVM_TEST_DIR-$TESTOLDPWD}"
+RUNNING_DMEVENTD=$(pgrep dmeventd) || true
 
-export COMMON_PREFIX
-export PREFIX
-export TESTDIR
+export TESTOLDPWD TESTDIR COMMON_PREFIX PREFIX RUNNING_DMEVENTD
 
-trap 'set +vx; STACKTRACE; set -vx' ERR
+test -n "$BASH" && trap 'set +vx; STACKTRACE; set -vx' ERR
 trap 'aux teardown' EXIT # don't forget to clean up
 
-export LVM_SYSTEM_DIR=$TESTDIR/etc
-DM_DEV_DIR=$TESTDIR/dev
-mkdir $LVM_SYSTEM_DIR $TESTDIR/lib $DM_DEV_DIR
+DM_DEV_DIR="$TESTDIR/dev"
+LVM_SYSTEM_DIR="$TESTDIR/etc"
+mkdir "$LVM_SYSTEM_DIR" "$TESTDIR/lib" "$DM_DEV_DIR"
 if test -n "$LVM_TEST_DEVDIR" ; then
-	DM_DEV_DIR="$LVM_TEST_DEVDIR"
+	DM_DEV_DIR=$LVM_TEST_DEVDIR
 else
-	mknod $DM_DEV_DIR/testnull c 1 3 || exit 1;
-	echo >$DM_DEV_DIR/testnull || { echo "Filesystem does support devices in $DM_DEV_DIR (mounted with nodev?)"; exit 1; }
-	mkdir -p $DM_DEV_DIR/mapper
+	mknod "$DM_DEV_DIR/testnull" c 1 3 || die "mknod failed";
+	echo >"$DM_DEV_DIR/testnull" || \
+		die "Filesystem does support devices in $DM_DEV_DIR (mounted with nodev?)"
+	mkdir "$DM_DEV_DIR/mapper"
 fi
-export DM_DEV_DIR
 
-cd $TESTDIR
+export DM_DEV_DIR LVM_SYSTEM_DIR
 
-for i in `find $abs_top_builddir/daemons/dmeventd/plugins/ -name \*.so`; do
-	#echo Setting up symlink from $i to $TESTDIR/lib
-	ln -s $i $TESTDIR/lib
-done
+cd "$TESTDIR"
 
-ln -s $abs_top_builddir/test/lib/* $TESTDIR/lib
+echo "$TESTNAME" >TESTNAME
 
-# re-do the utils now that we have TESTDIR/PREFIX/...
-. lib/utils
+# Setting up symlink from $i to $TESTDIR/lib
+find "$abs_top_builddir/daemons/dmeventd/plugins/" -name \*.so \
+	-exec ln -s "{}" lib/ \;
+ln -s "$abs_top_builddir/test/lib/"* lib/
+
+# Set vars from utils now that we have TESTDIR/PREFIX/...
+prepare_test_vars
+
+test -n "$BASH" && set -eE -o pipefail
 
-set -eE -o pipefail
 aux lvmconf
 aux prepare_clvmd
 test -n "$LVM_TEST_LVMETAD" && {
-    aux prepare_lvmetad
-    export LVM_LVMETAD_SOCKET="$TESTDIR/lvmetad.socket"
+	aux prepare_lvmetad
+	export LVM_LVMETAD_SOCKET="$TESTDIR/lvmetad.socket"
 }
 echo "@TESTDIR=$TESTDIR"
 echo "@PREFIX=$PREFIX"
--- LVM2/test/lib/utils.sh	2011/06/29 21:56:46	1.8
+++ LVM2/test/lib/utils.sh	2012/03/16 12:59:43	1.9
@@ -10,193 +10,192 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 set -e
+MAX_TRIES=4
 
-die() { echo >&2 "$@"; exit 1; }
+die() {
+	echo "$@" >&2
+	return 1
+}
 
-MAX_TRIES=4
+rand_bytes() {
+	n=$1
 
-rand_bytes()
-{
-  n=$1
-
-  chars=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789
-
-  dev_rand=/dev/urandom
-  if test -r "$dev_rand"; then
-    # Note: 256-length($chars) == 194; 3 copies of $chars is 186 + 8 = 194.
-    head -c$n "$dev_rand" | tr -c $chars 01234567$chars$chars$chars
-    return
-  fi
-
-  cmds='date; date +%N; free; who -a; w; ps auxww; ps ef; netstat -n'
-  data=$( (eval "$cmds") 2>&1 | gzip )
-
-  n_plus_50=$(expr $n + 50)
-
-  # Ensure that $data has length at least 50+$n
-  while :; do
-    len=$(echo "$data"|wc -c)
-    test $n_plus_50 -le $len && break;
-    data=$( (echo "$data"; eval "$cmds") 2>&1 | gzip )
-  done
-
-  echo "$data" \
-    | dd bs=1 skip=50 count=$n 2>/dev/null \
-    | tr -c $chars 01234567$chars$chars$chars
-}
-
-mkdtemp()
-{
-  case $# in
-  2);;
-  *) die "Usage: mkdtemp DIR TEMPLATE";;
-  esac
-
-  destdir=$1
-  template=$2
-
-  case $template in
-  *XXXX) ;;
-  *) die "invalid template: $template (must have a suffix of at least 4 X's)";;
-  esac
-
-  fail=0
-
-  # First, try to use mktemp.
-  d=$(env -u TMPDIR mktemp -d -t -p "$destdir" "$template" 2>/dev/null) \
-    || fail=1
-
-  # The resulting name must be in the specified directory.
-  case $d in "$destdir"*);; *) fail=1;; esac
-
-  # It must have created the directory.
-  test -d "$d" || fail=1
-
-  # It must have 0700 permissions.
-  perms=$(ls -dgo "$d" 2>/dev/null) || fail=1
-  case $perms in drwx------*) ;; *) fail=1;; esac
-
-  test $fail = 0 && {
-    echo "$d"
-    return
-  }
-
-  # If we reach this point, we'll have to create a directory manually.
-
-  # Get a copy of the template without its suffix of X's.
-  base_template=$(echo "$template"|sed 's/XX*$//')
-
-  # Calculate how many X's we've just removed.
-  nx=$(expr length "$template" - length "$base_template")
-
-  err=
-  i=1
-  while :; do
-    X=$(rand_bytes $nx)
-    candidate_dir="$destdir/$base_template$X"
-    err=$(mkdir -m 0700 "$candidate_dir" 2>&1) \
-      && { echo "$candidate_dir"; return; }
-    test $MAX_TRIES -le $i && break;
-    i=$(expr $i + 1)
-  done
-  die "$err"
+	chars="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
+
+	dev_rand="/dev/urandom"
+	if test -r "$dev_rand"; then
+		# Note: 256-length($chars) == 194; 3 copies of $chars is 186 + 8 = 194.
+		head -c"$n" "$dev_rand" | tr -c "$chars" "01234567$chars$chars$chars"
+		return
+	fi
+
+	cmds='date; date +%N; free; who -a; w; ps auxww; ps ef; netstat -n'
+	data=$( (eval "$cmds") 2>&1 | gzip )
+
+	n_plus_50=$(expr $n + 50)
+
+	# Ensure that $data has length at least 50+$n
+	while :; do
+		len=$(echo "$data" | wc -c)
+		test $n_plus_50 -le $len && break;
+		data=$( (echo "$data"; eval "$cmds") 2>&1 | gzip )
+	done
+
+	echo "$data" | dd bs=1 skip=50 count=$n 2>/dev/null \
+		| tr -c "$chars" "01234567$chars$chars$chars"
+}
+
+mkdtemp() {
+	case $# in
+		2) ;;
+		*) die "Usage: mkdtemp DIR TEMPLATE";;
+	esac
+
+	destdir=$1
+	template=$2
+
+	case "$template" in
+		*XXXX) ;;
+		*) die "Invalid template: $template (must have a suffix of at least 4 X's)";;
+	esac
+
+	fail=0
+
+	# First, try to use mktemp.
+	d=$(env -u TMPDIR mktemp -d -t -p "$destdir" "$template" 2>/dev/null) \
+	  || fail=1
+
+	# The resulting name must be in the specified directory.
+	case "$d" in "${destdir}"*);; *) fail=1;; esac
+
+	# It must have created the directory.
+	test -d "$d" || fail=1
+
+	# It must have 0700 permissions.
+	perms=$(ls -dgo "$d" 2>/dev/null) || fail=1
+	case "$perms" in drwx------*) ;; *) fail=1;; esac
+
+	test $fail = 0 && { echo "$d"; return; }
+
+	# If we reach this point, we'll have to create a directory manually.
+
+	# Get a copy of the template without its suffix of X's.
+	base_template=$(echo "$template" | sed 's/XX*$//')
+
+	# Calculate how many X's we've just removed.
+	nx=$(expr length "$template" - length "$base_template")
+
+	err=
+	i=1
+	while :; do
+		X=$(rand_bytes "$nx")
+		candidate_dir="$destdir/$base_template$X"
+		err=$(mkdir -m 0700 "$candidate_dir" 2>&1) && \
+			{ echo "$candidate_dir"; return; }
+		test $MAX_TRIES -le $i && break;
+		i=$(expr $i + 1)
+	done
+	die "$err"
 }
 
 STACKTRACE() {
-    trap - ERR;
-    i=0;
+	trap - ERR
+	local i=0
 
-    while FUNC=${FUNCNAME[$i]}; test "$FUNC" != "main"; do 
-	echo "## $i ${FUNC}() called from ${BASH_SOURCE[$i]}:${BASH_LINENO[$i]}"
-	i=$(($i + 1));
-    done
-
-    # Get backtraces from coredumps
-    if which gdb >& /dev/null; then
-	echo bt full > gdb_commands.txt
-	echo l >> gdb_commands.txt
-	echo quit >> gdb_commands.txt
-	for core in `ls core* 2>/dev/null`; do
-	    bin=$(gdb -batch -c $core 2>&1 | grep "generated by" | \
-		sed -e "s,.*generated by \`\([^ ']*\).*,\1,")
-	    gdb -batch -c $core -x gdb_commands.txt `which $bin`
+	echo "## - $0:${BASH_LINENO[0]}"
+	while FUNC=${FUNCNAME[$i]}; test "$FUNC" != "main"; do
+		echo "## $i ${FUNC}() called from ${BASH_SOURCE[$i]}:${BASH_LINENO[$i]}"
+		i=$(($i + 1))
 	done
-    fi
 
-    test -z "$LVM_TEST_NODEBUG" && test -f debug.log && {
-	sed -e "s,^,## DEBUG: ,;s,$top_srcdir/\?,," < debug.log
-    }
+	test -n "$RUNNING_DMEVENTD" -o -f LOCAL_DMEVENTD || {
+		pgrep dmeventd &>/dev/null && \
+			die "** During test dmeventd has been started!"
+	}
+
+	# Get backtraces from coredumps
+	if which gdb &>/dev/null; then
+		echo bt full > gdb_commands.txt
+		echo l >> gdb_commands.txt
+		echo quit >> gdb_commands.txt
+		for core in $(ls core* 2>/dev/null); do
+			bin=$(gdb -batch -c "$core" 2>&1 | grep "generated by" | \
+			sed -e "s,.*generated by \`\([^ ']*\).*,\1,")
+			gdb -batch -c "$core" -x gdb_commands.txt $(which "$bin")
+		done
+	fi
+
+	test -z "$LVM_TEST_NODEBUG" -a -f debug.log && {
+		sed -e "s,^,## DEBUG: ,;s,$top_srcdir/\?,," < debug.log
+	}
 
-    test -f SKIP_THIS_TEST && exit 200
+	test -f SKIP_THIS_TEST && exit 200
 }
 
 init_udev_transaction() {
-    if test "$DM_UDEV_SYNCHRONISATION" = 1; then
-	COOKIE=$(dmsetup udevcreatecookie)
-	# Cookie is not generated if udev is not running!
-	if test -n "$COOKIE"; then
-	    export DM_UDEV_COOKIE=$COOKIE
+	if test "$DM_UDEV_SYNCHRONISATION" = 1; then
+		local cookie=$(dmsetup udevcreatecookie)
+		# Cookie is not generated if udev is not running!
+		test -z "$cookie" || export DM_UDEV_COOKIE=$cookie
 	fi
-    fi
 }
 
 finish_udev_transaction() {
-    if test "$DM_UDEV_SYNCHRONISATION" = 1 -a -n "$DM_UDEV_COOKIE"; then
-	dmsetup udevreleasecookie
-	unset DM_UDEV_COOKIE
-    fi
+	if test "$DM_UDEV_SYNCHRONISATION" = 1 -a -n "$DM_UDEV_COOKIE"; then
+		dmsetup udevreleasecookie
+		unset DM_UDEV_COOKIE
+	fi
 }
 
 teardown_udev_cookies() {
-    if test "$DM_UDEV_SYNCHRONISATION" = 1; then
-	# Delete any cookies created more than 10 minutes ago 
-	# and not used in the last 10 minutes.
-	dmsetup udevcomplete_all -y 10
-    fi
+	if test "$DM_UDEV_SYNCHRONISATION" = 1; then
+		# Delete any cookies created more than 10 minutes ago
+		# and not used in the last 10 minutes.
+		# Log only non-zero semaphores count
+		(dmsetup udevcomplete_all -y 10 | grep -v "^0 ") || true
+	fi
 }
 
 skip() {
-    touch SKIP_THIS_TEST
-    exit 200
+	touch SKIP_THIS_TEST
+	exit 200
 }
 
 kernel_at_least() {
-    major=$(uname -r |cut -d. -f1)
-    minor=$(uname -r |cut -d. -f2 | cut -d- -f1)
+	local major=$(uname -r | cut -d. -f1)
+	local minor=$(uname -r | cut -d. -f2 | cut -d- -f1)
 
-    test $major -gt $1 && return 0
-    test $major -lt $1 && return 1
-    test $minor -gt $2 && return 0
-    test $minor -lt $2 && return 1
-    test -z "$3" && return 0
-
-    minor2=$(uname -r | cut -d. -f3 | cut -d- -f1)
-    test -z "$minor2" -a $3 -ne 0 && return 1
-    test $minor2 -ge $3 2>/dev/null && return 0
-
-    return 1
+	test $major -gt $1 && return 0
+	test $major -eq $1 || return 1
+	test $minor -gt $2 && return 0
+	test $minor -eq $2 || return 1
+	test -z "$3" && return 0
+
+	local minor2=$(uname -r | cut -d. -f3 | cut -d- -f1)
+	test -z "$minor2" -a $3 -ne 0 && return 1
+	test $minor2 -lt $3 2>/dev/null || return 1
+}
+
+prepare_test_vars() {
+	vg="${PREFIX}vg"
+	lv=LV
+
+	for i in $(seq 1 16); do
+		name="${PREFIX}pv$i"
+		dev="$DM_DEV_DIR/mapper/$name"
+		eval "dev$i=\"$dev\""
+		eval "lv$i=LV$i"
+		eval "vg$i=${PREFIX}vg$i"
+	done
 }
 
-. lib/paths || { echo >&2 you must run make first; exit 1; }
-
-PATH=$abs_top_builddir/test/lib:$PATH
-LIBDIRS="libdm tools liblvm daemons/dmeventd daemons/dmeventd/plugins/lvm2 \
-         daemons/dmeventd/plugins/mirror daemons/dmeventd/plugins/snapshot"
+. lib/paths || die "you must run make first"
 
-for d in $LIBDIRS; do
-    LD_LIBRARY_PATH=$abs_top_builddir/$d:$LD_LIBRARY_PATH
+PATH="$abs_top_builddir/test/lib":$PATH
+for d in daemons/dmeventd/plugins/mirror daemons/dmeventd/plugins/snapshot \
+	daemons/dmeventd/plugins/lvm2 daemons/dmeventd liblvm tools libdm; do
+	LD_LIBRARY_PATH="$abs_top_builddir/$d":$LD_LIBRARY_PATH
 done
-export LD_LIBRARY_PATH
+export PATH LD_LIBRARY_PATH
 
-if test -n "$PREFIX"; then
-    vg=${PREFIX}vg
-    lv=LV
-
-    for i in `seq 1 16`; do
-        name="${PREFIX}pv$i"
-        dev="$DM_DEV_DIR/mapper/$name"
-        eval "dev$i=$dev"
-        eval "lv$i=LV$i"
-        eval "vg$i=${PREFIX}vg$i"
-    done
-fi
+test -z "$PREFIX" || prepare_test_vars


