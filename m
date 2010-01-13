From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 13 Jan 2010 21:48:39 -0000
Subject: LVM2 WHATS_NEW WHATS_NEW_DM
Message-ID: <20100113214839.11044.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-13 21:48:39

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 

Log message:
	update WHATS_NEW and WHATS_NEW_DM to include snapshot-merge changes

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1384&r2=1.1385
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.334&r2=1.335

--- LVM2/WHATS_NEW	2010/01/13 17:40:17	1.1384
+++ LVM2/WHATS_NEW	2010/01/13 21:48:39	1.1385
@@ -2,6 +2,7 @@
 ===================================
   Fix clvmd automatic target module loading crash.
   Fix allocation code not to stop at the first area of a PV that fits.
+  Add --merge to lvconvert to merge a snapshot into its origin.
 
 Version 2.02.57 - 12th January 2010
 ===================================
--- LVM2/WHATS_NEW_DM	2010/01/12 14:47:00	1.334
+++ LVM2/WHATS_NEW_DM	2010/01/13 21:48:39	1.335
@@ -1,5 +1,7 @@
 Version 1.02.42 - 
 ===================================
+  Add support for the "snapshot-merge" target.
+  Introduce a third activation_proiority level in dm_tree_activate_children.
 
 Version 1.02.41 - 12th January 2010
 ===================================


