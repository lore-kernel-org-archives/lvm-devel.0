From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Dec 2010 11:19:22 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20101209111922.6949.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-12-09 11:19:21

Modified files:
	test           : test-utils.sh 

Log message:
	Try to detect fail in clvmd startup in tests.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.55&r2=1.56

--- LVM2/test/test-utils.sh	2010/10/29 16:43:52	1.55
+++ LVM2/test/test-utils.sh	2010/12/09 11:19:21	1.56
@@ -77,6 +77,10 @@
 
 	clvmd -Isinglenode -d 1 &
 	LOCAL_CLVMD="$!"
+
+	# check that it is really running now
+	sleep .1
+	ps $LOCAL_CLVMD || exit 200
 }
 
 prepare_dmeventd() {
@@ -396,6 +400,7 @@
     locking_dir = "$TESTDIR/var/lock/lvm"
     $locktype
     si_unit_consistency = 1
+    fallback_to_local_locking = 0
   }
   activation {
     udev_sync = 1


