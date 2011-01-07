From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 7 Jan 2011 13:03:47 -0000
Subject: LVM2/test/lib check.sh
Message-ID: <20110107130347.23378.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-01-07 13:03:47

Modified files:
	test/lib       : check.sh 

Log message:
	Relax the mirror test in test/lib/check.sh.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/check.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/lib/check.sh	2011/01/05 00:16:21	1.1
+++ LVM2/test/lib/check.sh	2011/01/07 13:03:46	1.2
@@ -140,9 +140,15 @@
 mirror_nonredundant() {
 	lv="$1/$2"
 	lvs -oattr "$lv" | grep -q "^ *m.....$" || {
-		echo "$lv expected a mirror, but is not:"
-		lvs -a $lv
-		exit 1
+		if lvs -oattr "$lv" | grep -q "^ *o.....$" &&
+		   lvs -a | fgrep -q "[${lv}_mimage"; then
+			echo "TEST WARNING: $lv is a snapshot origin and looks like a mirror,"
+			echo "assuming it is actually a mirror"
+		else
+			echo "$lv expected a mirror, but is not:"
+			lvs -a $lv
+			exit 1
+		fi
 	}
 	if test -n "$3"; then mirror_log_on "$1" "$2" "$3"; fi
 }


