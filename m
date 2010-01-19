From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 19 Jan 2010 17:06:51 -0000
Subject: LVM2/test t-topology-support.sh
Message-ID: <20100119170651.31641.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-19 17:06:50

Modified files:
	test           : t-topology-support.sh 

Log message:
	test/t-topology-support.sh requires scsi_debug from >= 2.6.31

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-topology-support.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/t-topology-support.sh	2010/01/19 16:44:57	1.1
+++ LVM2/test/t-topology-support.sh	2010/01/19 17:06:50	1.2
@@ -10,6 +10,11 @@
 
 which mkfs.ext3 || exit 200
 
+# Get linux minor version
+linux_minor=$(echo `uname -r` | cut -d'.' -f3 | cut -d'-' -f1)
+
+test $linux_minor -ge 31 || exit 200
+
 . ./test-utils.sh
 
 check_logical_block_size()


