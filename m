From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 9 Sep 2011 13:19:20 -0000
Subject: LVM2/test/lib check.sh
Message-ID: <20110909131920.32556.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-09 13:19:20

Modified files:
	test/lib       : check.sh 

Log message:
	Updated testing script
	
	Since attrs were extended by 2 new fields update check functions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/check.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/test/lib/check.sh	2011/04/12 12:39:24	1.5
+++ LVM2/test/lib/check.sh	2011/09/09 13:19:19	1.6
@@ -139,8 +139,8 @@
 
 mirror_nonredundant() {
 	lv="$1/$2"
-	lvs -oattr "$lv" | grep "^ *m.....$" >/dev/null || {
-		if lvs -oattr "$lv" | grep "^ *o.....$" >/dev/null &&
+	lvs -oattr "$lv" | grep "^ *m.......$" >/dev/null || {
+		if lvs -oattr "$lv" | grep "^ *o.......$" >/dev/null &&
 		   lvs -a | fgrep "[${2}_mimage" >/dev/null; then
 			echo "TEST WARNING: $lv is a snapshot origin and looks like a mirror,"
 			echo "assuming it is actually a mirror"
@@ -183,7 +183,7 @@
 
 active() {
 	lv="$1/$2"
-	lvl -oattr "$lv" 2> /dev/null | grep "^ *....a.$" >/dev/null || {
+	lvl -oattr "$lv" 2> /dev/null | grep "^ *....a...$" >/dev/null || {
 		echo "$lv expected active, but lvs says it's not:"
 		lvl "$lv" -o+devices 2>/dev/null
 		exit 1
@@ -197,7 +197,7 @@
 
 inactive() {
 	lv="$1/$2"
-	lvl -oattr "$lv" 2> /dev/null | grep '^ *....[-isd].$' >/dev/null || {
+	lvl -oattr "$lv" 2> /dev/null | grep '^ *....[-isd]...$' >/dev/null || {
 		echo "$lv expected inactive, but lvs says it's not:"
 		lvl "$lv" -o+devices 2>/dev/null
 		exit 1


