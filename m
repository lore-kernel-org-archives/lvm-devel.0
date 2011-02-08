From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 8 Feb 2011 22:35:12 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20110208223512.22432.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-02-08 22:35:11

Modified files:
	.              : WHATS_NEW 

Log message:
	orginal WHATS_NEW entry was changed to be less in-line with change it
	was associated with.  Update entry to be clearer than both.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1909&r2=1.1910

--- LVM2/WHATS_NEW	2011/02/08 12:41:08	1.1909
+++ LVM2/WHATS_NEW	2011/02/08 22:35:11	1.1910
@@ -40,7 +40,7 @@
   Replace fs_unlock by sync_local_dev_names to notify local clvmd. (2.02.80)
   Introduce sync_local_dev_names and CLVMD_CMD_SYNC_NAMES to issue fs_unlock.
   Accept fusion fio in device type filter.
-  Add disk to allowed mirrored log type conversions.
+  Add ability to convert mirror log type from disk to mirrored.
 
 Version 2.02.80 - 10th January 2011
 ===================================


