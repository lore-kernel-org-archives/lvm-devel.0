From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Jul 2010 22:56:46 -0000
Subject: LVM2 WHATS_NEW_DM
Message-ID: <20100705225646.18661.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-05 22:56:45

Modified files:
	.              : WHATS_NEW_DM 

Log message:
	Fix dmlosetup snprintf %llu compiler warning.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.388&r2=1.389

--- LVM2/WHATS_NEW_DM	2010/07/05 22:22:43	1.388
+++ LVM2/WHATS_NEW_DM	2010/07/05 22:56:45	1.389
@@ -1,5 +1,6 @@
 Version 1.02.52 -
 ================================
+  Fix dmlosetup snprintf %llu compiler warning.
   Add parentheses to some libdevmapper.h macro arguments.
   Add printf format attributes to dm_{sn,as}printf and fix a caller.
   Move dmeventd man page from install_lvm2 to install_device-mapper. (1.02.50)


