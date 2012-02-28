From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Feb 2012 17:47:24 -0000
Subject: LVM2 WHATS_NEW_DM
Message-ID: <20120228174724.2853.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-28 17:47:24

Modified files:
	.              : WHATS_NEW_DM 

Log message:
	Fix empty string warning logic in _find_config_str. (1.02.68)
	
	pvcreate gives
	WARNING: Ignoring unsupported value for metadata/pvmetadataignore.
	
	It was warning if there is no config file entry instead of only if the node
	exists but is empty.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.575&r2=1.576

--- LVM2/WHATS_NEW_DM	2012/02/28 08:36:51	1.575
+++ LVM2/WHATS_NEW_DM	2012/02/28 17:47:24	1.576
@@ -1,5 +1,6 @@
 Version 1.02.73 - 
 ====================================
+  Fix empty string warning logic in _find_config_str. (1.02.68)
   Fix dm_task_set_name to properly resolve path to dm name (1.02.71).
   Add dm_strncpy() function as a faster strncpy() replacement.
 


