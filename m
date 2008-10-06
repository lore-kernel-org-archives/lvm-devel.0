From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 6 Oct 2008 16:55:30 -0000
Subject: LVM2/test harness.sh test-utils.sh
Message-ID: <20081006165530.18997.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-10-06 16:55:30

Modified files:
	test           : harness.sh test-utils.sh 

Log message:
	Add a workaround for missing `losetup -s` by jstava, and a print a stacktrace
	on errors (also by jstava). Currently requires bash, a fix for that may come
	later -- explicitly using bash to run tests in the meantime.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/harness.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/harness.sh	2008/09/30 21:45:42	1.3
+++ LVM2/test/harness.sh	2008/10/06 16:55:29	1.4
@@ -5,7 +5,7 @@
 
 for t in $tests; do
     printf "Running %-40s" "$t ..."
-    out=`sh ./$t 2>&1`
+    out=`bash ./$t 2>&1`
     ret=$?
     if test $ret = 0; then
 	echo " passed."
--- LVM2/test/test-utils.sh	2008/09/30 15:20:09	1.2
+++ LVM2/test/test-utils.sh	2008/10/06 16:55:30	1.3
@@ -14,10 +14,20 @@
 aux() {
     # use just "$@" for verbose operation
     "$@" > /dev/null 2> /dev/null
+	#"$@"
 }
 
 not () { "$@" && exit 1 || return 0; }
 
+STACKTRACE() {
+	trap - ERR;
+	i=0;
+	while FUNC=${FUNCNAME[$i]}; test "$FUNC" != "main"; do 
+		echo "$i ${FUNC}() called from ${BASH_SOURCE[$i]}:${BASH_LINENO[$i]}"
+		i=$(($i + 1));
+	done
+}	
+
 teardown() {
     echo $LOOP
     echo $PREFIX
@@ -50,11 +60,32 @@
     test -n "$size" || size=32
 
     test -n "$LOOP" && return 0
-    trap "aux teardown" EXIT # don't forget to clean up
-
-    LOOPFILE=test.img
-    dd if=/dev/zero of=test.img bs=$((1024*1024)) count=1 seek=$(($size-1))
-    LOOP=`losetup -s -f test.img`
+	trap 'aux teardown' EXIT # don't forget to clean up
+	trap 'set +vex; STACKTRACE; set -vex' ERR
+	#trap - ERR
+
+	LOOPFILE="$PWD/test.img"
+	dd if=/dev/zero of="$LOOPFILE" bs=$((1024*1024)) count=1 seek=$(($size-1))
+	if LOOP=`losetup -s -f "$LOOPFILE" 2>/dev/null`; then
+		return 0
+	elif LOOP=`losetup -f` && losetup $LOOP "$LOOPFILE"; then
+		# no -s support
+		return 0
+	else
+		# no -f support 
+		# Iterate through $G_dev_/loop{,/}{0,1,2,3,4,5,6,7,8,9}
+		for slash in '' /; do
+			for i in 0 1 2 3 4 5 6 7 8 9; do
+				local dev=$G_dev_/loop$slash$i
+				! losetup $dev >/dev/null 2>&1 || continue
+				# got a free
+				losetup "$dev" "$LOOPFILE"
+				LOOP=$dev
+			done
+		done
+		test -n "LOOP" # confirm or fail
+	fi
+	exit 1 # should not be accesible
 }
 
 prepare_devs() {
@@ -142,6 +173,6 @@
 EOF
 }
 
-set -vex
+set -vexE
 aux prepare_lvmconf
 


