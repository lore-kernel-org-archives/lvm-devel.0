From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Jan 2011 16:08:39 -0000
Subject: LVM2/test/lib check.sh
Message-ID: <20110128160839.30974.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-28 16:08:39

Modified files:
	test/lib       : check.sh 

Log message:
	Do not break pipes
	
	As the option 'set -e -o pipefail' is very sensite on pipe breaking
	stop using '-q' for grep commands.
	
	Otherwise this command (with large enough table) would fail:
	
	dmsetup table | egrep -q
	
	with exit code 141 (128 + SIGPIPE)
	
	As Peter suggested, he prefers to keep '-o pipefail' - so make sure all
	piped commands will read the whole output and will not exit too early.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/check.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/lib/check.sh	2011/01/07 14:42:35	1.3
+++ LVM2/test/lib/check.sh	2011/01/28 16:08:39	1.4
@@ -139,9 +139,9 @@
 
 mirror_nonredundant() {
 	lv="$1/$2"
-	lvs -oattr "$lv" | grep -q "^ *m.....$" || {
-		if lvs -oattr "$lv" | grep -q "^ *o.....$" &&
-		   lvs -a | fgrep -q "[${2}_mimage"; then
+	lvs -oattr "$lv" | grep "^ *m.....$" >/dev/null || {
+		if lvs -oattr "$lv" | grep "^ *o.....$" >/dev/null &&
+		   lvs -a | fgrep "[${2}_mimage" >/dev/null; then
 			echo "TEST WARNING: $lv is a snapshot origin and looks like a mirror,"
 			echo "assuming it is actually a mirror"
 		else
@@ -174,7 +174,7 @@
 
 linear() {
 	lv="$1/$2"
-	lvl -ostripes "$lv" | grep -q "1" || {
+	lvl -ostripes "$lv" | grep "1" >/dev/null || {
 		echo "$lv expected linear, but is not:"
 		lvl "$lv" -o+devices
 		exit 1
@@ -183,12 +183,12 @@
 
 active() {
 	lv="$1/$2"
-	lvl -oattr "$lv" 2> /dev/null | grep -q "^ *....a.$" || {
+	lvl -oattr "$lv" 2> /dev/null | grep "^ *....a.$" >/dev/null || {
 		echo "$lv expected active, but lvs says it's not:"
 		lvl "$lv" -o+devices 2>/dev/null
 		exit 1
 	}
-	dmsetup table | egrep -q "$1-$2: *[^ ]+" || {
+	dmsetup table | egrep "$1-$2: *[^ ]+" >/dev/null || {
 		echo "$lv expected active, lvs thinks it is but there are no mappings!"
 		dmsetup table | grep $1-$2:
 		exit 1
@@ -197,12 +197,12 @@
 
 inactive() {
 	lv="$1/$2"
-	lvl -oattr "$lv" 2> /dev/null | grep -q '^ *....[-isd].$' || {
+	lvl -oattr "$lv" 2> /dev/null | grep '^ *....[-isd].$' >/dev/null || {
 		echo "$lv expected inactive, but lvs says it's not:"
 		lvl "$lv" -o+devices 2>/dev/null
 		exit 1
 	}
-	dmsetup table | not egrep -q "$1-$2: *[^ ]+" || {
+	dmsetup table | not egrep "$1-$2: *[^ ]+" >/dev/null || {
 		echo "$lv expected inactive, lvs thinks it is but there are mappings!"
 		dmsetup table | grep $1-$2:
 		exit 1


