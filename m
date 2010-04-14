From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Apr 2010 17:50:54 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20100414175054.17987.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-14 17:50:50

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.229&r2=1.230
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1521&r2=1.1522
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.354&r2=1.355

--- LVM2/VERSION	2010/03/09 14:01:47	1.229
+++ LVM2/VERSION	2010/04/14 17:50:49	1.230
@@ -1 +1 @@
-2.02.63(1)-cvs (2010-03-09)
+2.02.63(1)-cvs (2010-04-14)
--- LVM2/VERSION_DM	2010/03/09 14:01:47	1.41
+++ LVM2/VERSION_DM	2010/04/14 17:50:49	1.42
@@ -1 +1 @@
-1.02.46-cvs (2010-03-09)
+1.02.46-cvs (2010-04-14)
--- LVM2/WHATS_NEW	2010/04/14 13:52:20	1.1521
+++ LVM2/WHATS_NEW	2010/04/14 17:50:49	1.1522
@@ -1,5 +1,5 @@
-Version 2.02.63 -  
-================================
+Version 2.02.63 - 14th April 2010
+=================================
   Allow incomplete mirror restore in lvconvert --repair upon insufficient space.
   Do not reset position in metadata ring buffer on vgrename and vgcfgrestore.
   Allow VGs with active LVs to be renamed.
--- LVM2/WHATS_NEW_DM	2010/04/07 20:04:42	1.354
+++ LVM2/WHATS_NEW_DM	2010/04/14 17:50:49	1.355
@@ -1,5 +1,5 @@
-Version 1.02.46 - 
-================================
+Version 1.02.46 - 14th April 2010
+=================================
   Change dm_tree_deactivate_children to fail if device is open.
   Wipe memory buffers for dm-ioctl parameters before releasing.
   Strictly require libudev if udev_sync is used.


