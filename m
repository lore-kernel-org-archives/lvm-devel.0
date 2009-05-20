From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 20 May 2009 11:27:15 -0000
Subject: LVM2/test t-read-ahead.sh
Message-ID: <20090520112715.8784.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-20 11:27:15

Modified files:
	test           : t-read-ahead.sh 

Log message:
	Fix readahead test.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-read-ahead.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/t-read-ahead.sh	2009/05/20 11:09:50	1.6
+++ LVM2/test/t-read-ahead.sh	2009/05/20 11:27:14	1.7
@@ -47,6 +47,8 @@
 blockdev --setra 768 $dev1
 lvcreate -n $lv -L4M $vg $dev1
 test $(blockdev --getra $G_dev_/$vg/$lv) -eq 768
+lvremove -ff $vg
+
 # Check default, active/inactive values for read_ahead / kernel_read_ahead
 lvcreate -n $lv -l 50%FREE $vg
 lvchange -an $vg/$lv


