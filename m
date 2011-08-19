From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Aug 2011 16:31:00 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20110819163100.17820.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-08-19 16:31:00

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.284&r2=1.285
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.89&r2=1.90
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2080&r2=1.2081
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.493&r2=1.494

--- LVM2/VERSION	2011/08/12 02:34:08	1.284
+++ LVM2/VERSION	2011/08/19 16:31:00	1.285
@@ -1 +1 @@
-2.02.88(2)-cvs (2011-08-12)
+2.02.88(2)-cvs (2011-08-19)
--- LVM2/VERSION_DM	2011/08/12 02:34:08	1.89
+++ LVM2/VERSION_DM	2011/08/19 16:31:00	1.90
@@ -1 +1 @@
-1.02.67-cvs (2011-08-12)
+1.02.67-cvs (2011-08-19)
--- LVM2/WHATS_NEW	2011/08/19 15:59:15	1.2080
+++ LVM2/WHATS_NEW	2011/08/19 16:31:00	1.2081
@@ -1,4 +1,4 @@
-Version 2.02.88 - 
+Version 2.02.88 - 19th August 2011
 ==================================
   Add lvconvert --merge support for raid1 devices split with --trackchanges.
   Support lvconvert of -m1 raid1 devices to a higher number.
--- LVM2/WHATS_NEW_DM	2011/08/19 16:26:02	1.493
+++ LVM2/WHATS_NEW_DM	2011/08/19 16:31:00	1.494
@@ -1,4 +1,4 @@
-Version 1.02.67 - 
+Version 1.02.67 - 19th August 2011
 ==================================
   Add dm_tree_node_add_null_area for temporarily-missing raid devs tracked.
 


