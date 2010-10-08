From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Oct 2010 14:49:26 -0000
Subject: LVM2 ./WHATS_NEW scripts/fsadm.sh
Message-ID: <20101008144926.29999.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-08 14:49:26

Modified files:
	.              : WHATS_NEW 
	scripts        : fsadm.sh 

Log message:
	Fix assignment of default LVM variable
	
	Fix a typo which does not work in case LVM_BINARY is empty string.
	Using proper :-  syntax.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1750&r2=1.1751
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/WHATS_NEW	2010/10/08 13:49:20	1.1750
+++ LVM2/WHATS_NEW	2010/10/08 14:49:25	1.1751
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Fix assignment of default value to LVM variable is fsadm.
   Fix support for --yes flag for fsadm.
   Do not execute lvresize with --dry-run option for fsadm.
   Fix fsadm return error code from user's break action.
--- LVM2/scripts/fsadm.sh	2010/10/08 13:49:20	1.16
+++ LVM2/scripts/fsadm.sh	2010/10/08 14:49:26	1.17
@@ -49,7 +49,7 @@
 XFS_CHECK=xfs_check
 
 # user may override lvm location by setting LVM_BINARY
-LVM=${LVM_BINARY-lvm}
+LVM=${LVM_BINARY:-lvm}
 
 YES=${_FSADM_YES}
 DRY=0


