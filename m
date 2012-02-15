From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Feb 2012 13:51:19 -0000
Subject: LVM2/test/shell snapshot-merge.sh
Message-ID: <20120215135119.15037.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-15 13:51:18

Modified files:
	test/shell     : snapshot-merge.sh 

Log message:
	Deal with slower test processing
	
	If the merge was faster then query - deal with it and pass the test.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/snapshot-merge.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/shell/snapshot-merge.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/snapshot-merge.sh	2012/02/15 13:51:17	1.2
@@ -78,7 +78,8 @@
 # -- refresh LV to start merge (now that FS is unmounted),
 #    an active merge uses the 'snapshot-merge' target
 lvchange --refresh $vg/$lv1
-dmsetup table ${vg}-${lv1} | grep " snapshot-merge "
+# check whether it's still merging - or maybe got already merged (slow test)
+dmsetup table ${vg}-${lv1} | grep " snapshot-merge " || dmsetup table ${vg}-${lv1} | grep " linear "
 # -- don't care if merge is still active; lvremove at this point
 #    may test stopping an active merge
 lvremove -f $vg/$lv1


