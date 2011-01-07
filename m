From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 7 Jan 2011 14:42:36 -0000
Subject: LVM2/test/lib check.sh
Message-ID: <20110107144236.19736.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-01-07 14:42:36

Modified files:
	test/lib       : check.sh 

Log message:
	Fix a typo in the new relaxed mirror check (test/lib/check.sh).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/check.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/lib/check.sh	2011/01/07 13:03:46	1.2
+++ LVM2/test/lib/check.sh	2011/01/07 14:42:35	1.3
@@ -141,7 +141,7 @@
 	lv="$1/$2"
 	lvs -oattr "$lv" | grep -q "^ *m.....$" || {
 		if lvs -oattr "$lv" | grep -q "^ *o.....$" &&
-		   lvs -a | fgrep -q "[${lv}_mimage"; then
+		   lvs -a | fgrep -q "[${2}_mimage"; then
 			echo "TEST WARNING: $lv is a snapshot origin and looks like a mirror,"
 			echo "assuming it is actually a mirror"
 		else


