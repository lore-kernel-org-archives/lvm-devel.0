From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Jan 2012 03:56:19 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20120120035619.26882.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-01-20 03:56:18

Modified files:
	.              : WHATS_NEW 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2225&r2=1.2226

--- LVM2/WHATS_NEW	2012/01/20 00:27:18	1.2225
+++ LVM2/WHATS_NEW	2012/01/20 03:56:18	1.2226
@@ -1,6 +1,5 @@
 Version 2.02.89 - 
 ==================================
-  Preserve exclusive activation of cluster mirror when converting.
   Keep info about creation host and time for each logical volume.
   Make error message hit when preallocated memlock memory exceeded clearer.
   Use R lv_attr to indicate read-only activation of non-read-only device in lvs.
@@ -192,7 +191,7 @@
   Append 'm' attribute to pv_attr for missing PVs.
   Annotate CLVMD_CMD_SYNC_NAMES in decode_cmd.
   Remove enforcement of udev verification when using non-standard /dev location.
-  Fix to preserve exclusive activation of mirror while up-converting.
+  Keep an exclusive mirror non-clustered if reloaded e.g. during conversion.
   Reject allocation if number of extents is not divisible by area count.
   Fix cluster mirror creation to work with new mirror allocation algorithm.
   Ignore activation/verify_udev_operations if dm kernel driver vsn < 4.18.


