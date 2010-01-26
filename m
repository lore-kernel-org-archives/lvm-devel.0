From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 26 Jan 2010 07:58:24 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20100126075824.22084.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-01-26 07:58:23

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Fix return code of info callbacks.
	
	In dev_manager_info 0 means error and 1 info is returned,
	not that device exists (that value is part of info struct).
	
	Fix query by uuid only (no name) which returns 0 when device
	does not exist.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1407&r2=1.1408
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.177&r2=1.178

--- LVM2/WHATS_NEW	2010/01/23 02:14:30	1.1407
+++ LVM2/WHATS_NEW	2010/01/26 07:58:23	1.1408
@@ -1,5 +1,6 @@
 Version 2.02.60 - 23rd January 2010
 ===================================
+  Fix return code of info call for query by uuid.
   Extend cmirrord man page.
   Sleep before first progress check if pvmove/lvconvert interval has prefix '+'.
   Default to checking progress before waiting in _wait_for_single_lv.
--- LVM2/lib/activate/dev_manager.c	2010/01/22 15:40:32	1.177
+++ LVM2/lib/activate/dev_manager.c	2010/01/26 07:58:23	1.178
@@ -209,14 +209,16 @@
 		 int with_open_count, int with_read_ahead,
 		 struct dm_info *info, uint32_t *read_ahead)
 {
+	int r = 0;
+
 	if (!mknodes && dlid && *dlid) {
-		if (_info_run(NULL, dlid, info, read_ahead, 0, with_open_count,
-			      with_read_ahead, 0, 0) &&
+		if ((r = _info_run(NULL, dlid, info, read_ahead, 0, with_open_count,
+			      with_read_ahead, 0, 0)) &&
 	    	    info->exists)
 			return 1;
-		else if (_info_run(NULL, dlid + sizeof(UUID_PREFIX) - 1, info,
+		else if ((r = _info_run(NULL, dlid + sizeof(UUID_PREFIX) - 1, info,
 				   read_ahead, 0, with_open_count,
-				   with_read_ahead, 0, 0) &&
+				   with_read_ahead, 0, 0)) &&
 			 info->exists)
 			return 1;
 	}
@@ -225,7 +227,7 @@
 		return _info_run(name, NULL, info, read_ahead, mknodes,
 				 with_open_count, with_read_ahead, 0, 0);
 
-	return 0;
+	return r;
 }
 
 static int _info_by_dev(uint32_t major, uint32_t minor, struct dm_info *info)


