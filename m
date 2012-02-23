From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Feb 2012 22:24:48 -0000
Subject: LVM2/lib cache/lvmetad.c metadata/lv_manip.c m ...
Message-ID: <20120223222448.5441.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-23 22:24:47

Modified files:
	lib/cache      : lvmetad.c 
	lib/metadata   : lv_manip.c mirror.c 
	lib/mirror     : mirrored.c 

Log message:
	Drop backtrace after log_error
	
	Just a minor change to not give backtrace when log_error has been just
	reported.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.365&r2=1.366
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.178&r2=1.179
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95

--- LVM2/lib/cache/lvmetad.c	2012/02/23 19:03:48	1.3
+++ LVM2/lib/cache/lvmetad.c	2012/02/23 22:24:47	1.4
@@ -245,7 +245,7 @@
 	 * request.  */
 	if (!export_vg_to_buffer(vg, &buf)) {
 		log_error("Could not format VG metadata.");
-		return_0;
+		return 0;
 	}
 
 	reply = daemon_send_simple(_lvmetad, "vg_update", "vgname = %s", vg->name,
--- LVM2/lib/metadata/lv_manip.c	2012/02/23 17:36:36	1.365
+++ LVM2/lib/metadata/lv_manip.c	2012/02/23 22:24:47	1.366
@@ -2331,7 +2331,7 @@
 
 	if (dm_list_size(&lv->segments) != 1 || seg_type(seg, 0) != AREA_LV) {
 		log_error("Mirror layer must be inserted before adding mirrors");
-		return_0;
+		return 0;
 	}
 
 	mirror_segtype = get_segtype_from_string(lv->vg->cmd, "mirror");
--- LVM2/lib/metadata/mirror.c	2012/02/08 12:52:59	1.178
+++ LVM2/lib/metadata/mirror.c	2012/02/23 22:24:47	1.179
@@ -873,7 +873,7 @@
 			if ((s == 0) && !_mirrored_lv_in_sync(lv) &&
 			    !(lv->status & PARTIAL_LV)) {
 				log_error("Unable to remove primary mirror image while mirror is not in-sync");
-				return_0;
+				return 0;
 			}
 			if (!shift_mirror_images(mirrored_seg, s))
 				return_0;
@@ -1015,7 +1015,7 @@
 		if (!resume_lv(detached_log_lv->vg->cmd, detached_log_lv)) {
 			log_error("Failed to resume %s",
 				  detached_log_lv->name);
-			return_0;
+			return 0;
 		}
 	}
 
@@ -1091,7 +1091,7 @@
 			/* As a result, unnecessary sync may run after
 			 * collapsing. But safe.*/
 			log_error("Failed to initialize log device");
-			return_0;
+			return 0;
 		}
 	}
 
@@ -2136,7 +2136,7 @@
 	/* Can't split a mirror that is not in-sync... unless force? */
 	if (!_mirrored_lv_in_sync(lv)) {
 		log_error("Unable to split mirror that is not in-sync.");
-		return_0;
+		return 0;
 	}
 
 	/*
--- LVM2/lib/mirror/mirrored.c	2012/02/13 11:07:55	1.94
+++ LVM2/lib/mirror/mirrored.c	2012/02/23 22:24:47	1.95
@@ -251,7 +251,7 @@
 	if (num_devs > DEFAULT_MIRROR_MAX_IMAGES || num_devs < 0) {
 		log_error("Unexpectedly many (%d) mirror images in %s.",
 			  num_devs, lv->name);
-		return_0;
+		return 0;
 	}
 
 	args = alloca((num_devs + 5) * sizeof(char *));
@@ -265,7 +265,7 @@
 	if (log_argc > 16 || log_argc < 0) {
 		log_error("Unexpectedly many (%d) log arguments in %s.",
 			  log_argc, lv->name);
-		return_0;
+		return 0;
 	}
 
 	log_args = alloca(log_argc * sizeof(char *));
@@ -277,7 +277,7 @@
 	if (num_devs != seg->area_count) {
 		log_error("Active mirror has a wrong number of mirror images!");
 		log_error("Metadata says %d, kernel says %d.", seg->area_count, num_devs);
-		return_0;
+		return 0;
 	}
 
 	if (!strcmp(log_args[0], "disk")) {
@@ -293,7 +293,7 @@
 		if (strcmp(buf, log_args[1])) {
 			log_error("Mirror log mismatch. Metadata says %s, kernel says %s.",
 				  buf, log_args[1]);
-			return_0;
+			return 0;
 		}
 		log_very_verbose("Status of log (%s): %s", buf, log_args[2]);
 		if (log_args[2][0] != 'A') {
@@ -327,7 +327,7 @@
 	for (i = 0; i < num_devs; ++i) {
 		if (!images[i]) {
 			log_error("Failed to find image %d (%s).", i, args[i]);
-			return_0;
+			return 0;
 		}
 		log_very_verbose("Status of image %d: %c", i, status[i]);
 		if (status[i] != 'A') {


