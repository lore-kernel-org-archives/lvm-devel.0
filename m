From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Sep 2011 19:37:27 -0000
Subject: LVM2/test t-fsadm.sh
Message-ID: <20110919193727.25238.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-19 19:37:26

Modified files:
	test           : t-fsadm.sh 

Log message:
	Unmount works with -y

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-fsadm.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/test/t-fsadm.sh	2011/09/19 13:52:22	1.7
+++ LVM2/test/t-fsadm.sh	2011/09/19 19:37:26	1.8
@@ -117,8 +117,9 @@
 	fscheck_reiserfs
 	mount $dev_vg_lv $mount_dir
 
-	not fsadm -y --lvresize resize $vg_lv 20M
+	fsadm -y --lvresize resize $vg_lv 30M
 	umount $mount_dir
+	fscheck_reiserfs
 
 	lvresize -f -L20M $vg_lv
 fi


