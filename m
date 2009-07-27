From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 27 Jul 2009 21:10:30 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090727211030.21131.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-27 21:10:30

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW for latest liblvm changes

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1204&r2=1.1205

--- LVM2/WHATS_NEW	2009/07/26 22:19:14	1.1204
+++ LVM2/WHATS_NEW	2009/07/27 21:10:30	1.1205
@@ -1,5 +1,17 @@
 Version 2.02.50 - 
 ================================
+  Remove unnecessary \n's from log_error in liblvm.
+  Add config_reload and config_override to test.c, change prompt.
+  Add lvm_config_override - allow caller to override LVM config.
+  Refactor _override_settings into override_config_tree_from_string and move.
+  Add skeletons of lvm_lv_resize and lvm_pv_resize - not yet implemented.
+  Update test/api/test.c to include lvm_vg_reduce and lvm_vg_extend.
+  Add lvm_vg_reduce to liblvm.
+  Add vg_reduce to metadata.c and metadata-exported.h.
+  Update error return and comments for lvm_list_vg_names/uuids.
+  Rename lvm_reload_config to lvm_config_reload.
+  Update display.c to use vg_free(vg) instead of duplicating the calculation.
+  More liblvm header file cleanups.
   Update liblvm unit tests in test/api for latest liblvm changes.
   Add lvm_lv_is_active and lvm_lv_is_suspended liblvm APIs.
   Add lvm_lv_activate and lvm_lv_deactivate liblvm APIs.


