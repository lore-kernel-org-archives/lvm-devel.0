From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 Apr 2010 19:33:58 -0000
Subject: LVM2/test check.sh
Message-ID: <20100412193358.4116.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-04-12 19:33:58

Modified files:
	test           : check.sh 

Log message:
	More testsuite helpers for check.sh.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/check.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/check.sh	2010/04/12 19:02:59	1.1
+++ LVM2/test/check.sh	2010/04/12 19:33:58	1.2
@@ -26,14 +26,33 @@
   }
 }
 
+mirror_images_on() {
+	lv=$1
+
+	for i in `lvdevices $lv`; do
+		shift
+		lv_on $lv $1
+	done
+}
+
+lv_on()
+{
+	lv="$1"
+	lvdevices $lv | grep -F "$2" || {
+		echo "LV $lv expected on $2 but is not:" >&2
+		lvdevices $lv >&2
+		exit 1
+	}
+	test `lvdevices $lv | grep -vF "$2" | wc -l` -eq 0 || {
+		echo "LV $lv contains unexpected devices:" >&2
+		lvdevices $lv >&2
+		exit 1
+	}
+}
+
 mirror_log_on()
 {
-  lv="$1"_mlog
-  lvdevices $lv | grep -F "$2" || {
-	  echo "mirror log $lv expected on $2 but found on:" >&2
-	  lvdevices $lv >&2
-	  exit 1
-  }
+	lv_on "${1}_mlog" "$2"
 }
 
 lv_is_contiguous()
@@ -81,7 +100,7 @@
 
 linear() {
 	lv="$1/$2"
-	lvs -ostripes "$lv" | grep "1" || {
+	lvs -ostripes "$lv" | grep -q "1" || {
 		echo "$lv expected linear, but is not:"
 		lvs -a "$lv" -o+devices
 		exit 1


