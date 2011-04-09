From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 9 Apr 2011 19:05:26 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20110409190526.30443.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-04-09 19:05:24

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c mirror.c 
	tools          : lvconvert.c 

Log message:
	Fix incorrect tests for dm_snprintf() failure
	
	As the memory is preallocated based on arg size in these cases,
	the error would be quite hard to trigger here anyway.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1969&r2=1.1970
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.257&r2=1.258
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.148&r2=1.149
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.160&r2=1.161

--- LVM2/WHATS_NEW	2011/04/08 14:40:18	1.1969
+++ LVM2/WHATS_NEW	2011/04/09 19:05:23	1.1970
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Fix incorrect tests for dm_snprintf() failure.
   Fix some unmatching sign comparation gcc warnings in the code.
   Allow lv_extend() to work on zero length intrinsically layered LVs.
   Keep the cache content when the exported vg buffer is matching.
--- LVM2/lib/metadata/lv_manip.c	2011/04/08 14:40:19	1.257
+++ LVM2/lib/metadata/lv_manip.c	2011/04/09 19:05:24	1.258
@@ -2296,7 +2296,7 @@
 		log_error("Failed to allocate space for new name");
 		return 0;
 	}
-	if (!dm_snprintf(new_name, len, "%s%s", lv_name_new, suffix)) {
+	if (dm_snprintf(new_name, len, "%s%s", lv_name_new, suffix) < 0) {
 		log_error("Failed to create new name");
 		return 0;
 	}
--- LVM2/lib/metadata/mirror.c	2011/04/08 14:40:20	1.148
+++ LVM2/lib/metadata/mirror.c	2011/04/09 19:05:24	1.149
@@ -1787,7 +1787,7 @@
 	} else if ((lv_name = strstr(lv->name, MIRROR_SYNC_LAYER))) {
 		len = lv_name - lv->name + 1;
 		if (!(tmp_name = alloca(len)) ||
-		    !dm_snprintf(tmp_name, len, "%s", lv->name)) {
+		    (dm_snprintf(tmp_name, len, "%s", lv->name) < 0)) {
 			log_error("mirror log name allocation failed");
 			return 0;
 		}
--- LVM2/tools/lvconvert.c	2011/04/08 14:40:21	1.160
+++ LVM2/tools/lvconvert.c	2011/04/09 19:05:24	1.161
@@ -481,7 +481,7 @@
 	if (!uuid || !lv_full_name)
 		return_0;
 
-	if (!dm_snprintf(lv_full_name, len, "%s/%s", lv->vg->name, lv->name))
+	if (dm_snprintf(lv_full_name, len, "%s/%s", lv->vg->name, lv->name) < 0)
 		return_0;
 
 	memcpy(uuid, &lv->lvid, sizeof(lv->lvid));


