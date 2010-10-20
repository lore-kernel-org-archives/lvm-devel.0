From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Oct 2010 15:14:13 -0000
Subject: LVM2/test test-utils.sh t-test-partition.sh
Message-ID: <20101020151413.9437.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-20 15:14:13

Modified files:
	test           : test-utils.sh 
Added files:
	test           : t-test-partition.sh 

Log message:
	Add coverage test for partition table scanning

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-test-partition.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.52&r2=1.53

/cvs/lvm2/LVM2/test/t-test-partition.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-test-partition.sh
+++ -	2010-10-20 15:14:13.391062000 +0000
@@ -0,0 +1,30 @@
+#!/bin/sh
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+#
+# Testcase for bugzilla #621173 
+# excercises partition table scanning code path
+#
+
+which sfdisk || exit 200
+
+LVM_TEST_CONFIG_DEVICES="types = [\"device-mapper\", 142]"
+
+. ./test-utils.sh
+
+aux prepare_pvs 1 30
+
+pvs
+
+# create small partition table
+echo "1 2" | sfdisk $dev1
+
+pvs
--- LVM2/test/test-utils.sh	2010/10/15 16:28:15	1.52
+++ LVM2/test/test-utils.sh	2010/10/20 15:14:13	1.53
@@ -370,6 +370,7 @@
     cache_dir = "$TESTDIR/etc"
     sysfs_scan = 0
     default_data_alignment = 1
+    $LVM_TEST_CONFIG_DEVICES
   }
   log {
     syslog = 0


