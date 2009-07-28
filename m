From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Jul 2009 19:32:30 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090728193230.12497.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-28 19:32:28

Modified files:
	.              : WHATS_NEW 

Log message:
	clean up a bit for release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1206&r2=1.1207

--- LVM2/WHATS_NEW	2009/07/28 17:07:48	1.1206
+++ LVM2/WHATS_NEW	2009/07/28 19:32:26	1.1207
@@ -1,37 +1,33 @@
 Version 2.02.50 - 28th July 2009
 ================================
-  Remove unnecessary \n's from log_error in liblvm.
-  Add config_reload and config_override to test.c, change prompt.
-  Add lvm_config_override - allow caller to override LVM config.
-  Refactor _override_settings into override_config_tree_from_string and move.
-  Add skeletons of lvm_lv_resize and lvm_pv_resize - not yet implemented.
-  Update test/api/test.c to include lvm_vg_reduce and lvm_vg_extend.
-  Add lvm_vg_reduce to liblvm.
-  Add vg_reduce to metadata.c and metadata-exported.h.
-  Update error return and comments for lvm_list_vg_names/uuids.
+  Change test/api/test.c prompt so it's not confused with the main lvm prompt.
+  Update liblvm unit tests in test/api to cover latest liblvm changes.
+  Add unimplemented lvm_lv_resize and lvm_pv_resize skeletons to liblvm.
+  Add lvm_library_get_version to liblvm.
+  Add lvm_config_override to liblvm to allow caller to override LVM config.
+  Add lvm_lv_is_active and lvm_lv_is_suspended to liblvm.
+  Add lvm_lv_activate and lvm_lv_deactivate to liblvm.
+  Add lvm_scan, lvm_vg_reduce and lvm_vg_remove_lv to liblvm.
+  Add functions to get numeric properties to liblvm.
+  Add lvm_{pv|vg|lv}_get_{name|uuid} to liblvm.
+  Add lvm_vg_list_pvs and lvm_vg_list_lvs to liblvm.
+  Add lvm_vg_open and lvm_vg_create_lv_linear to liblvm.
+  Add lvm_list_vg_names/uuids to liblvm.
+  Add lvm_errno and lvm_errmsg to liblvm to obtain failure information.
+  Rename lvm_create/destroy to lvm_init/quit.
   Rename lvm_reload_config to lvm_config_reload.
-  Update display.c to use vg_free(vg) instead of duplicating the calculation.
-  More liblvm header file cleanups.
-  Update liblvm unit tests in test/api for latest liblvm changes.
-  Add lvm_lv_is_active and lvm_lv_is_suspended liblvm APIs.
-  Add lvm_lv_activate and lvm_lv_deactivate liblvm APIs.
-  Add lvm_scan liblvm function.
+  Refactor _override_settings to use new override_config_tree_from_string.
+  Add vg_reduce to metadata.c and metadata-exported.h.
   Update lvm.h to clarify API behavior and return codes.
-  Add lvm_vg_remove_lv liblvm function.
-  Add numeric liblvm 'get' functions required by anaconda.
-  Refactor vg_size, vg_free, and pv_mda_count field calculations for liblvm.
-  Update test/api/test.c to call new liblvm functions.
-  Add liblvm function lvm_vg_create_lv_linear.
   Update lvm_vg_extend to do an implicit pvcreate on the device.
+  Update display.c to use vg_free(vg) instead of duplicating the calculation.
+  Refactor vg_size, vg_free, and pv_mda_count field calculations for liblvm.
   Refactor pvcreate and lvcreate for liblvm.
   Add global/wait_for_locks to lvm.conf so blocking for locks can be disabled.
   All LV locks are non-blocking so remove LCK_NONBLOCK from separate macros.
   Fix race condition with vgcreate and vgextend on same device (2.02.49).
   Remove redundant validate_name call from vgreduce.
-  Add lvm_{pv|vg|lv}_get_{name|uuid} liblvm functions.
-  Add lvm_vg_list_pvs and lvm_vg_list_lvs liblvm functions.
   Remove unused handles lvseg, pvseg inside liblvm/lvm.h.
-  Add lvm_vg_open liblvm function.
   Add liblvm2app Makefile installation targets.
   Add liblvm pkgconfig file.
   Use newly-independent LVM_LIBAPI in liblvm soname.  E.g. liblvm2app.so.2.1.
@@ -40,7 +36,6 @@
   Return EINVALID_CMD_LINE not success when invalid VG name format is used.
   Remove unnecessary messages after vgcreate/vgsplit refactor (2.02.49).
   Add log_errno to set a specific errno and replace log_error in due course.
-  Add lvm_errno and lvm_errmsg to liblvm to obtain failure information.
   Change create_toolcontext to still return an object if it fails part-way.
   Add EUNCLASSIFIED (-1) as the default LVM errno code.
   Store any errno and error messages issued while processing each command.


