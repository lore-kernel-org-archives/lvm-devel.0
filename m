From: agk@sourceware.org <agk@sourceware.org>
Date: 4 Feb 2011 22:35:30 -0000
Subject: LVM2 WHATS_NEW_DM
Message-ID: <20110204223530.839.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-02-04 22:35:30

Modified files:
	.              : WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.442&r2=1.443

--- LVM2/WHATS_NEW_DM	2011/02/04 22:07:44	1.442
+++ LVM2/WHATS_NEW_DM	2011/02/04 22:35:29	1.443
@@ -1,5 +1,7 @@
 Version 1.02.62 - 4th February 2011
 ===================================
+  Add configure --with-device-nodes-on=create for previous behaviour.
+  Move creation of device nodes from 'create' to 'resume'.
   Add --addnodeonresume and --addnodeoncreate options to dmsetup.
   Add dm_task_set_add_node to libdevmapper to control dev node creation time.
   Add dm_task_secure_data to libdevmapper to wipe ioctl buffers in kernel.


