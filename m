From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Nov 2011 22:44:23 -0000
Subject: LVM2 doc/example.conf.in lib/config/defaults.h ...
Message-ID: <20111104224423.1670.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-04 22:44:22

Modified files:
	doc            : example.conf.in 
	lib/config     : defaults.h 
	lib/metadata   : lv_manip.c 

Log message:
	Thin add thin_pool_metadata_require_separate_pvs
	
	Allow to set different policy for pool from mirrors.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.86&r2=1.87
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.321&r2=1.322

--- LVM2/doc/example.conf.in	2011/10/11 09:13:39	1.34
+++ LVM2/doc/example.conf.in	2011/11/04 22:44:21	1.35
@@ -213,6 +213,11 @@
 #    until version 2.02.85.
 #
 #    mirror_logs_require_separate_pvs = 0
+#
+#    Set to 1 to guarantee that thin pool metadata will always
+#    be placed on different PVs from the pool data.
+#
+#    thin_pool_metadata_require_separate_pvs = 0
 #}
 
 # This section that allows you to configure the nature of the
--- LVM2/lib/config/defaults.h	2011/11/04 22:43:10	1.86
+++ LVM2/lib/config/defaults.h	2011/11/04 22:44:21	1.87
@@ -60,6 +60,7 @@
 #define DEFAULT_DMEVENTD_MONITOR 1
 #define DEFAULT_BACKGROUND_POLLING 1
 
+#define DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
 #define DEFAULT_THIN_POOL_MAX_METADATA_SIZE (16 * 1024 * 1024)  /* KB */
 #define DEFAULT_THIN_POOL_MIN_METADATA_SIZE 2048  /* KB */
 
--- LVM2/lib/metadata/lv_manip.c	2011/11/04 22:43:10	1.321
+++ LVM2/lib/metadata/lv_manip.c	2011/11/04 22:44:22	1.322
@@ -788,6 +788,8 @@
 	ah->region_size = region_size;
 	ah->alloc = alloc;
 	ah->area_multiple = _calc_area_multiple(segtype, area_count, stripes);
+	ah->mirror_logs_separate = find_config_tree_bool(cmd, "allocation/mirror_logs_require_separate_pvs",
+							 DEFAULT_MIRROR_LOGS_REQUIRE_SEPARATE_PVS);
 
 	if (segtype_is_raid(segtype)) {
 		if (metadata_area_count) {
@@ -813,6 +815,9 @@
 		/* thin_pool uses region_size to pass metadata size in extents */
 		ah->log_len = ah->region_size;
 		ah->region_size = 0;
+		ah->mirror_logs_separate =
+			find_config_tree_bool(cmd, "allocation/thin_pool_metadata_require_separate_pvs",
+					      DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS);
 	} else {
 		ah->log_area_count = metadata_area_count;
 		ah->log_len = !metadata_area_count ? 0 :
@@ -829,8 +834,6 @@
 
 	ah->maximise_cling = find_config_tree_bool(cmd, "allocation/maximise_cling", DEFAULT_MAXIMISE_CLING);
 
-	ah->mirror_logs_separate = find_config_tree_bool(cmd, "allocation/mirror_logs_require_separate_pvs", DEFAULT_MIRROR_LOGS_REQUIRE_SEPARATE_PVS);
-
 	return ah;
 }
 


