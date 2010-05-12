From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 May 2010 05:55:09 -0000
Subject: LVM2/test check.sh
Message-ID: <20100512055509.5248.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-05-12 05:55:08

Modified files:
	test           : check.sh 

Log message:
	Improve the "check" testing utility: slightly refactor and provide
	active/inactive checks.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/check.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/check.sh	2010/05/06 19:01:26	1.3
+++ LVM2/test/check.sh	2010/05/12 05:55:08	1.4
@@ -2,8 +2,12 @@
 
 set -e -o pipefail
 
+lvl() {
+	lvs -a --noheadings "$@"
+}
+
 lvdevices() {
-	lvs -a -odevices --noheadings "$@" | sed 's/([^)]*)//g; s/,/ /g'
+	lvl -odevices "$@" | sed 's/([^)]*)//g; s/,/ /g'
 }
 
 mirror_images_redundant()
@@ -57,9 +61,9 @@
 
 lv_is_contiguous()
 {
-	test `lvs -a --segments --noheadings $1 | wc -l` -eq 1 || {
+	test `lvl --segments $1 | wc -l` -eq 1 || {
 		echo "LV $1 expected to be contiguous, but is not:"
-		lvs -a --segments --noheadings $1
+		lvl --segments $1
 		exit 1
 	}
 }
@@ -89,9 +93,9 @@
 
 mirror() {
 	lv="$1/$2"
-	lvs -oattr "$lv" | grep "m" || {
+	lvl -oattr "$lv" | grep "m" || {
 		echo "$lv expected a mirror, but is not:"
-		lvs -a $lv
+		lvl -a $lv
 		exit 1
 	}
 	mirror_images_redundant "$1" "$2"
@@ -108,9 +112,37 @@
 
 linear() {
 	lv="$1/$2"
-	lvs -ostripes "$lv" | grep -q "1" || {
+	lvl -ostripes "$lv" | grep -q "1" || {
 		echo "$lv expected linear, but is not:"
-		lvs -a "$lv" -o+devices
+		lvl "$lv" -o+devices
+		exit 1
+	}
+}
+
+active() {
+	lv="$1/$2"
+	lvl -oattr "$lv" 2> /dev/null | grep -q "^ *....a.$" || {
+		echo "$lv expected active, but lvs says it's not:"
+		lvl "$lv" -o+devices 2>/dev/null
+		exit 1
+	}
+	dmsetup table | egrep -q "$1-$2: *[^ ]+" || {
+		echo "$lv expected active, lvs thinks it is but there are no mappings!"
+		dmsetup table | grep $1-$2:
+		exit 1
+	}
+}
+
+inactive() {
+	lv="$1/$2"
+	lvl -oattr "$lv" 2> /dev/null | grep -q '^ *....[-isd].$' || {
+		echo "$lv expected inactive, but lvs says it's not:"
+		lvl "$lv" -o+devices 2>/dev/null
+		exit 1
+	}
+	dmsetup table | not egrep -q "$1-$2: *[^ ]+" || {
+		echo "$lv expected inactive, lvs thinks it is but there are mappings!"
+		dmsetup table | grep $1-$2:
 		exit 1
 	}
 }


