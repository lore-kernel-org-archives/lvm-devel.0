From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Jul 2011 12:49:51 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20110708124951.14341.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-07-08 12:49:50

Modified files:
	.              : WHATS_NEW 

Log message:
	Move snapshot removal activation logic into lib/activate.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2037&r2=1.2038

--- LVM2/WHATS_NEW	2011/07/06 00:29:44	1.2037
+++ LVM2/WHATS_NEW	2011/07/08 12:49:50	1.2038
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Move snapshot removal activation logic into lib/activate.
   Cope with a PV only discovered missing when creating deptree.
   Abort operation if dm_tree_node_add_target_area fails.
   Add activation/checks to lvm.conf to perform additional ioctl validation.


