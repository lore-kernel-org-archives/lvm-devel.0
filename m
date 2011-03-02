From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 2 Mar 2011 20:00:10 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20110302200010.15824.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-03-02 20:00:09

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h 
	tools          : toollib.c vgchange.c 

Log message:
	PE size overflows, on most architectures it is catch by "PE cannot be 0"
	but s390x unfortunately return something usable.
	
	Always use unit64 in inital parameter check.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1932&r2=1.1933
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.184&r2=1.185
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.223&r2=1.224
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.119&r2=1.120

--- LVM2/WHATS_NEW	2011/03/02 16:56:06	1.1932
+++ LVM2/WHATS_NEW	2011/03/02 20:00:09	1.1933
@@ -1,6 +1,6 @@
 Version 2.02.85 - 
 ===================================
-  Fix possible overwlow in maximum stripe size.
+  Fix possible overflow in maximum stripe size and physical extent size.
   Add test for failed allocation from dm_task_set_uuid() in dmeventd.
   Improve pvremove error message when PV belongs to a VG.
   Extend normal policy to allow mirror logs on same PVs as images if necessary.
--- LVM2/lib/metadata/metadata-exported.h	2011/02/28 13:19:02	1.184
+++ LVM2/lib/metadata/metadata-exported.h	2011/03/02 20:00:09	1.185
@@ -34,6 +34,7 @@
 #define STRIPE_SIZE_MAX ( 512L * 1024L >> SECTOR_SHIFT)	/* 512 KB in sectors */
 #define STRIPE_SIZE_LIMIT ((UINT_MAX >> 2) + 1)
 #define MAX_RESTRICTED_LVS 255	/* Used by FMT_RESTRICTED_LVIDS */
+#define MAX_EXTENT_SIZE ((uint32_t) -1)
 
 /* Layer suffix */
 #define MIRROR_SYNC_LAYER "_mimagetmp"
--- LVM2/tools/toollib.c	2011/03/02 16:56:07	1.223
+++ LVM2/tools/toollib.c	2011/03/02 20:00:09	1.224
@@ -1238,6 +1238,12 @@
 		return 1;
 	}
 
+	if (arg_uint64_value(cmd, physicalextentsize_ARG, 0) > MAX_EXTENT_SIZE) {
+		log_error("Physical extent size cannot be larger than %s",
+				  display_size(cmd, (uint64_t) MAX_EXTENT_SIZE));
+		return 1;
+	}
+
 	if (arg_sign_value(cmd, maxlogicalvolumes_ARG, 0) == SIGN_MINUS) {
 		log_error("Max Logical Volumes may not be negative");
 		return 1;
--- LVM2/tools/vgchange.c	2011/02/04 20:30:19	1.119
+++ LVM2/tools/vgchange.c	2011/03/02 20:00:09	1.120
@@ -356,6 +356,12 @@
 {
 	uint32_t extent_size;
 
+	if (arg_uint64_value(cmd, physicalextentsize_ARG, 0) > MAX_EXTENT_SIZE) {
+		log_error("Physical extent size cannot be larger than %s",
+				  display_size(cmd, (uint64_t) MAX_EXTENT_SIZE));
+		return 1;
+	}
+
 	extent_size = arg_uint_value(cmd, physicalextentsize_ARG, 0);
 	/* FIXME: remove check - redundant with vg_change_pesize */
 	if (extent_size == vg->extent_size) {


