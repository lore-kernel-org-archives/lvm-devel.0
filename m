From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 26 Jan 2010 08:00:04 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c
Message-ID: <20100126080004.23012.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-01-26 08:00:03

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 

Log message:
	Unlock shared lock if activation calls failed.
	
	Clvmd should unlock new lock if activation in device-mapper fails.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1408&r2=1.1409
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84

--- LVM2/WHATS_NEW	2010/01/26 07:58:23	1.1408
+++ LVM2/WHATS_NEW	2010/01/26 08:00:02	1.1409
@@ -1,5 +1,6 @@
 Version 2.02.60 - 23rd January 2010
 ===================================
+  Unlock shared lock in clvmd if activation calls failed.
   Fix return code of info call for query by uuid.
   Extend cmirrord man page.
   Sleep before first progress check if pvmove/lvconvert interval has prefix '+'.
--- LVM2/daemons/clvmd/lvm-functions.c	2010/01/19 13:25:00	1.83
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/01/26 08:00:03	1.84
@@ -373,17 +373,22 @@
 
 	/* If it's suspended then resume it */
 	if (!lv_info_by_lvid(cmd, resource, &lvi, 0, 0))
-		return EIO;
+		goto error;
 
 	if (lvi.suspended)
 		if (!lv_resume(cmd, resource))
-			return EIO;
+			goto error;
 
 	/* Now activate it */
 	if (!lv_activate(cmd, resource, exclusive))
-		return EIO;
+		goto error;
 
 	return 0;
+
+error:
+	if (oldmode == -1 || oldmode != mode)
+		(void)hold_unlock(resource);
+	return EIO;
 }
 
 /* Resume the LV if it was active */


