From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Jun 2010 12:19:58 -0000
Subject: LVM2 ./WHATS_NEW liblvm/.exported_symbols libl ...
Message-ID: <20100625121958.20229.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-06-25 12:19:55

Modified files:
	.              : WHATS_NEW 
	liblvm         : .exported_symbols Makefile.in 

Log message:
	Update liblvm2app exported symbols.
	Add Makefile target to generate current list of lvm2app.h functions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1635&r2=1.1636
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/WHATS_NEW	2010/06/24 08:29:30	1.1635
+++ LVM2/WHATS_NEW	2010/06/25 12:19:52	1.1636
@@ -1,5 +1,7 @@
 Version 2.02.69 - 
 ================================
+  Update liblvm2app exported symbols.
+  Add manual Makefile target to generate current list of lvm2app.h functions.
   Preload libc locale messages to prevent reading it in memory locked state.
   Fix handling of simultaneous mirror image and mirrored log image failure.
 
--- LVM2/liblvm/.exported_symbols	2010/05/19 11:53:12	1.26
+++ LVM2/liblvm/.exported_symbols	2010/06/25 12:19:54	1.27
@@ -1,52 +1,59 @@
-lvm_library_get_version
-lvm_init
-lvm_quit
-lvm_config_reload
 lvm_config_override
-lvm_pv_get_dev_size
-lvm_pv_get_size
-lvm_pv_get_free
-lvm_pv_get_name
-lvm_pv_get_uuid
-lvm_pv_get_mda_count
-lvm_vg_get_seqno
-lvm_vg_get_name
-lvm_vg_get_uuid
-lvm_vg_get_size
-lvm_vg_get_free_size
-lvm_vg_get_extent_size
-lvm_vg_get_extent_count
-lvm_vg_get_free_extent_count
-lvm_vg_get_pv_count
-lvm_vg_get_tags
+lvm_config_reload
+lvm_errmsg
+lvm_errno
+lvm_init
+lvm_library_get_version
+lvm_list_vg_names
+lvm_list_vg_uuids
 lvm_lv_activate
+lvm_lv_add_tag
 lvm_lv_deactivate
-lvm_lv_get_uuid
 lvm_lv_get_name
 lvm_lv_get_size
+lvm_lv_get_tags
+lvm_lv_get_uuid
 lvm_lv_is_active
 lvm_lv_is_suspended
-lvm_lv_add_tag
 lvm_lv_remove_tag
-lvm_lv_get_tags
+lvm_lv_resize
+lvm_pv_get_dev_size
+lvm_pv_get_free
+lvm_pv_get_mda_count
+lvm_pv_get_name
+lvm_pv_get_size
+lvm_pv_get_uuid
+lvm_pv_resize
+lvm_quit
+lvm_scan
+lvm_vg_add_tag
+lvm_vg_close
 lvm_vg_create
+lvm_vg_create_lv_linear
 lvm_vg_extend
-lvm_vg_reduce
-lvm_vg_set_extent_size
-lvm_vg_write
+lvm_vg_get_extent_count
+lvm_vg_get_extent_size
+lvm_vg_get_free_extent_count
+lvm_vg_get_free_size
+lvm_vg_get_max_lv
+lvm_vg_get_max_pv
+lvm_vg_get_name
+lvm_vg_get_pv_count
+lvm_vg_get_seqno
+lvm_vg_get_size
+lvm_vg_get_tags
+lvm_vg_get_uuid
+lvm_vg_is_clustered
+lvm_vg_is_exported
+lvm_vg_is_partial
+lvm_vg_list_lvs
+lvm_vg_list_pvs
+lvm_vgname_from_device
+lvm_vgname_from_pvid
 lvm_vg_open
-lvm_vg_close
+lvm_vg_reduce
 lvm_vg_remove
-lvm_vg_add_tag
-lvm_vg_remove_tag
-lvm_scan
-lvm_errno
-lvm_errmsg
-lvm_vg_list_pvs
-lvm_vg_list_lvs
-lvm_list_vg_names
-lvm_list_vg_uuids
-lvm_vg_create_lv_linear
 lvm_vg_remove_lv
-lvm_vgname_from_pvid
-lvm_vgname_from_device
+lvm_vg_remove_tag
+lvm_vg_set_extent_size
+lvm_vg_write
--- LVM2/liblvm/Makefile.in	2010/05/11 08:57:03	1.23
+++ LVM2/liblvm/Makefile.in	2010/06/25 12:19:55	1.24
@@ -75,4 +75,8 @@
 
 cflow: liblvm.cflow
 
+.exported_symbols_new: $(srcdir)/lvm2app.h
+	$(CPP) -P $< | \
+	$(SED) -ne '/^(typedef|})/!s/.*[ \*]\(lvm_[a-z_]*\)(.*/\1/p' > $@
+
 DISTCLEAN_TARGETS += $(LIB_NAME).pc


