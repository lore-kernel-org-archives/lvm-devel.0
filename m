From: agk@sourceware.org <agk@sourceware.org>
Date: 20 May 2009 22:44:11 -0000
Subject: LVM2 WHATS_NEW_DM
Message-ID: <20090520224411.6015.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-05-20 22:44:11

Modified files:
	.              : WHATS_NEW_DM 

Log message:
	Missing entries.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.266&r2=1.267

--- LVM2/WHATS_NEW_DM	2009/04/24 11:30:49	1.266
+++ LVM2/WHATS_NEW_DM	2009/05/20 22:44:10	1.267
@@ -1,6 +1,10 @@
 Version 1.02.32 - 
 ================================
-  Fix segfault when using -U, -G and -M options in dmsetup.
+  Only generate libdevmapper.a when configured to link statically.
+  Export dm_tree_node_size_changed() from libdevmapper.
+  Propagate the table size_changed property up the dm device tree.
+  Detect failure to free memory pools when releasing the library.
+  Fix segfault when getopt processes dmsetup -U, -G and -M options.
 
 Version 1.02.31 - 3rd March 2009
 ================================


