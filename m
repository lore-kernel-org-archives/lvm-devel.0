From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 28 Jun 2010 19:13:34 -0000
Subject: LVM2/test t-lvconvert-mirror-basic.sh
Message-ID: <20100628191334.22782.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-06-28 19:13:34

Modified files:
	test           : t-lvconvert-mirror-basic.sh 

Log message:
	Minor shell style cleanup.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror-basic.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/t-lvconvert-mirror-basic.sh	2010/05/12 13:15:38	1.2
+++ LVM2/test/t-lvconvert-mirror-basic.sh	2010/06/28 19:13:33	1.3
@@ -2,9 +2,9 @@
 
 log_name_to_count()
 {
-	if [ $1 == "mirrored" ]; then
+	if [ "$1" = "mirrored" ]; then
 		echo 2
-	elif [ $1 == "disk" ]; then
+	elif [ "$1" = "disk" ]; then
 		echo 1
 	else
 		echo 0
@@ -44,8 +44,8 @@
 	local active=true
 	local i
 
-	if [ $start_log_type == "disk" ] &&
-		[ $finish_log_type == "mirrored" ]; then
+	if [ "$start_log_type" = "disk" ] &&
+		[ "$finish_log_type" = "mirrored" ]; then
 		echo "FIXME:  disk -> mirrored log conversion not yet supported by LVM"
 		return 0
 	fi


