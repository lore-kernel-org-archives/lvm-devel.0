From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 24 May 2010 17:18:25 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20100524171825.32344.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-05-24 17:18:12

Modified files:
	test           : test-utils.sh 

Log message:
	Replace lvm.conf instead of truncating it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.44&r2=1.45

--- LVM2/test/test-utils.sh	2010/05/24 15:32:21	1.44
+++ LVM2/test/test-utils.sh	2010/05/24 17:18:05	1.45
@@ -358,7 +358,7 @@
 		filter='[ "a/dev\/mirror/", "a/dev\/mapper\/.*pv[0-9_]*$/", "r/.*/" ]'
         locktype=
 	if test -n "$LVM_TEST_LOCKING"; then locktype="locking_type = $LVM_TEST_LOCKING"; fi
-	cat > $TESTDIR/etc/lvm.conf <<-EOF
+	cat > $TESTDIR/etc/lvm.conf.new <<-EOF
   $LVM_TEST_CONFIG
   devices {
     dir = "$DM_DEV_DIR"
@@ -391,6 +391,8 @@
     polling_interval = 0
   }
 EOF
+	# FIXME remove this workaround after mmap & truncating file problems solved
+	mv $TESTDIR/etc/lvm.conf.new $TESTDIR/etc/lvm.conf
 	cat $TESTDIR/etc/lvm.conf
 }
 


