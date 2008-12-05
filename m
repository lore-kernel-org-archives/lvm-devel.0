From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 5 Dec 2008 05:03:24 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20081205050324.20366.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-12-05 05:03:24

Modified files:
	test           : test-utils.sh 

Log message:
	Fix test-utils.h for rhel4 backward compatability.
	
	for losetup, break out of the loop when successful setup of loop device,
	and only look at 7 loop devices (default loop module setting)
	for blockdev, use old option if new one is not available

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/test-utils.sh	2008/11/10 12:36:23	1.6
+++ LVM2/test/test-utils.sh	2008/12/05 05:03:23	1.7
@@ -73,15 +73,19 @@
 		return 0
 	else
 		# no -f support 
-		# Iterate through $G_dev_/loop{,/}{0,1,2,3,4,5,6,7,8,9}
+		# Iterate through $G_dev_/loop{,/}{0,1,2,3,4,5,6,7}
 		for slash in '' /; do
-			for i in 0 1 2 3 4 5 6 7 8 9; do
+			for i in 0 1 2 3 4 5 6 7; do
 				local dev=$G_dev_/loop$slash$i
 				! losetup $dev >/dev/null 2>&1 || continue
 				# got a free
 				losetup "$dev" "$LOOPFILE"
 				LOOP=$dev
+				break
 			done
+			if [ -n "$LOOP" ]; then 
+				break
+			fi
 		done
 		test -n "$LOOP" # confirm or fail
 		return 0
@@ -99,7 +103,10 @@
 
 	PREFIX="LVMTEST$$"
 
-	local loopsz=`blockdev --getsz $LOOP`
+	if ! loopsz=`blockdev --getsz $LOOP 2>/dev/null`; then
+  		loopsz=`blockdev --getsize $LOOP 2>/dev/null`
+	fi
+
 	local size=$(($loopsz/$n))
 
 	for i in `seq 1 $n`; do


