From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 5 Jan 2011 00:25:16 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20110105002516.9877.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-01-05 00:25:10

Modified files:
	test/lib       : aux.sh 

Log message:
	Fix a couple of bugs in the new (test/lib/)aux.sh.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/lib/aux.sh	2011/01/05 00:16:21	1.1
+++ LVM2/test/lib/aux.sh	2011/01/05 00:25:07	1.2
@@ -43,7 +43,10 @@
 	fi
 
 	# skip if we don't have our own dmeventd...
-	(which dmeventd | grep $abs_builddir) || exit 200
+	(which dmeventd | grep $abs_builddir) || {
+            touch SKIP_THIS_TEST
+            exit 1
+        }
 
 	dmeventd -f &
 	echo "$!" > LOCAL_DMEVENTD
@@ -219,6 +222,7 @@
 	fi
 
 	local size=$(($loopsz/$n))
+        devs=
 
 	init_udev_transaction
 	for i in `seq 1 $n`; do


