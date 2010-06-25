From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Jun 2010 18:17:40 -0000
Subject: LVM2 ./WHATS_NEW ./make.tmpl.in libdm/.exporte ...
Message-ID: <20100625181740.30268.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-06-25 18:17:39

Modified files:
	.              : WHATS_NEW make.tmpl.in 
	libdm          : .exported_symbols Makefile.in 
	liblvm         : .exported_symbols Makefile.in 

Log message:
	Generate liblvm2app and libdevmapper exported symbols from header files.
	
	Detection is simply by prefix - dm_ or lvm_ - and any additional symbols needed
	but not detected this way are placed in .exported_symbols.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1636&r2=1.1637
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.103&r2=1.104
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/.exported_symbols.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/Makefile.in.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/WHATS_NEW	2010/06/25 12:19:52	1.1636
+++ LVM2/WHATS_NEW	2010/06/25 18:17:38	1.1637
@@ -1,7 +1,6 @@
 Version 2.02.69 - 
 ================================
-  Update liblvm2app exported symbols.
-  Add manual Makefile target to generate current list of lvm2app.h functions.
+  Generate liblvm2app and libdevmapper exported symbols from header file.
   Preload libc locale messages to prevent reading it in memory locked state.
   Fix handling of simultaneous mirror image and mirrored log image failure.
 
--- LVM2/make.tmpl.in	2010/06/03 13:52:21	1.103
+++ LVM2/make.tmpl.in	2010/06/25 18:17:38	1.104
@@ -355,7 +355,16 @@
 	test -z "$(DISTCLEAN_DIRS)" || $(RM) -r $(DISTCLEAN_DIRS)
 	$(RM) $(DISTCLEAN_TARGETS) Makefile core
 
-.export.sym: .exported_symbols
+.exported_symbols_generated: $(EXPORTED_HEADER) .exported_symbols
+	set -e; \
+	( cat $(srcdir)/.exported_symbols; \
+	  if test x$(EXPORTED_HEADER) != x; then \
+        	$(CC) -E -P $(EXPORTED_HEADER) | \
+        	$(SED) -ne "/^typedef|}/!s/.*[ \*]\(\$(EXPORTED_FN_PREFIX)_[a-z0-9_]*\)(.*/\1/p"; \
+	  fi \
+	) > $@
+
+.export.sym: .exported_symbols_generated
 	set -e; (echo "Base {"; echo "	global:"; \
 		 sed "s/^/		/;s/$$/;/" < $<; \
 		 echo "	local:"; echo "		*;"; echo "};") > $@
--- LVM2/libdm/.exported_symbols	2010/05/21 12:27:03	1.54
+++ LVM2/libdm/.exported_symbols	2010/06/25 18:17:39	1.55
@@ -1,177 +1,2 @@
-dm_lib_release
-dm_lib_exit
-dm_driver_version
-dm_create_dir
-dm_fclose
-dm_get_library_version
 dm_log
-dm_log_init
-dm_log_is_non_default
 dm_log_with_errno
-dm_log_with_errno_init
-dm_log_init_verbose
-dm_task_create
-dm_task_destroy
-dm_task_set_name
-dm_task_set_uuid
-dm_task_get_driver_version
-dm_task_get_info
-dm_task_get_deps
-dm_task_get_name
-dm_task_get_names
-dm_task_get_versions
-dm_task_get_uuid
-dm_task_get_read_ahead
-dm_task_set_ro
-dm_task_set_newname
-dm_task_set_cookie
-dm_task_set_event_nr
-dm_task_set_major
-dm_task_set_minor
-dm_task_set_major_minor
-dm_task_set_sector
-dm_task_set_message
-dm_task_set_uid
-dm_task_set_gid
-dm_task_set_mode
-dm_task_set_read_ahead
-dm_task_suppress_identical_reload
-dm_task_add_target
-dm_task_no_flush
-dm_task_no_open_count
-dm_task_skip_lockfs
-dm_task_query_inactive_table
-dm_task_update_nodes
-dm_task_run
-dm_get_next_target
-dm_set_dev_dir
-dm_dir
-dm_format_dev
-dm_tree_create
-dm_tree_free
-dm_tree_add_dev
-dm_tree_add_dev_with_udev_flags
-dm_tree_add_new_dev
-dm_tree_add_new_dev_with_udev_flags
-dm_tree_node_get_name
-dm_tree_node_get_uuid
-dm_tree_node_get_info
-dm_tree_node_get_context
-dm_tree_node_size_changed
-dm_tree_node_num_children
-dm_tree_node_num_parents
-dm_tree_find_node
-dm_tree_find_node_by_uuid
-dm_tree_next_child
-dm_tree_next_parent
-dm_tree_deactivate_children
-dm_tree_activate_children
-dm_tree_preload_children
-dm_tree_suspend_children
-dm_tree_children_use_uuid
-dm_tree_node_add_snapshot_origin_target
-dm_tree_node_add_snapshot_target
-dm_tree_node_add_snapshot_merge_target
-dm_tree_node_add_error_target
-dm_tree_node_add_zero_target
-dm_tree_node_add_linear_target
-dm_tree_node_add_striped_target
-dm_tree_node_add_crypt_target
-dm_tree_node_add_mirror_target
-dm_tree_node_add_mirror_target_log
-dm_tree_node_add_target_area
-dm_tree_node_add_replicator_target
-dm_tree_node_add_replicator_dev_target
-dm_tree_node_set_presuspend_node
-dm_tree_node_set_read_ahead
-dm_tree_skip_lockfs
-dm_tree_use_no_flush_suspend
-dm_tree_set_cookie
-dm_tree_get_cookie
-dm_is_dm_major
-dm_mknodes
-dm_malloc_aux
-dm_malloc_aux_debug
-dm_strdup_aux
-dm_free_aux
-dm_realloc_aux
-dm_dump_memory_debug
-dm_bounds_check_debug
-dm_pool_create
-dm_pool_destroy
-dm_pool_alloc
-dm_pool_alloc_aligned
-dm_pool_empty
-dm_pool_free
-dm_pool_begin_object
-dm_pool_grow_object
-dm_pool_end_object
-dm_pool_abandon_object
-dm_pool_strdup
-dm_pool_strndup
-dm_pool_zalloc
-dm_bitset_create
-dm_bitset_destroy
-dm_bitset_equal
-dm_bit_and
-dm_bit_union
-dm_bit_get_first
-dm_bit_get_next
-dm_hash_create
-dm_hash_destroy
-dm_hash_wipe
-dm_hash_lookup
-dm_hash_insert
-dm_hash_remove
-dm_hash_lookup_binary
-dm_hash_insert_binary
-dm_hash_remove_binary
-dm_hash_get_num_entries
-dm_hash_iter
-dm_hash_get_key
-dm_hash_get_data
-dm_hash_get_first
-dm_hash_get_next
-dm_set_selinux_context
-dm_task_set_geometry
-dm_split_lvm_name
-dm_split_words
-dm_snprintf
-dm_basename
-dm_asprintf
-dm_report_init
-dm_report_object
-dm_report_output
-dm_report_free
-dm_report_get_private
-dm_report_field_string
-dm_report_field_int
-dm_report_field_int32
-dm_report_field_uint32
-dm_report_field_uint64
-dm_report_field_set_value
-dm_report_set_output_field_name_prefix
-dm_regex_create
-dm_regex_match
-dm_list_init
-dm_list_add
-dm_list_add_h
-dm_list_del
-dm_list_move
-dm_list_splice
-dm_list_empty
-dm_list_start
-dm_list_end
-dm_list_first
-dm_list_last
-dm_list_prev
-dm_list_next
-dm_list_size
-dm_cookie_supported
-dm_udev_set_sync_support
-dm_udev_get_sync_support
-dm_udev_set_checking
-dm_udev_get_checking
-dm_udev_create_cookie
-dm_udev_complete
-dm_udev_wait
--- LVM2/libdm/Makefile.in	2010/05/11 08:57:03	1.55
+++ LVM2/libdm/Makefile.in	2010/06/25 18:17:39	1.56
@@ -45,6 +45,9 @@
 CFLOW_LIST = $(SOURCES)
 CFLOW_LIST_TARGET = libdevmapper.cflow
 
+EXPORTED_HEADER = $(srcdir)/libdevmapper.h
+EXPORTED_FN_PREFIX = dm
+
 include $(top_builddir)/make.tmpl
 
 DEFS += -DDM_DEVICE_UID=@DM_DEVICE_UID@ -DDM_DEVICE_GID=@DM_DEVICE_GID@ \
--- LVM2/liblvm/.exported_symbols	2010/06/25 12:21:47	1.28
+++ LVM2/liblvm/.exported_symbols	2010/06/25 18:17:39	1.29
@@ -1,59 +0,0 @@
-lvm_library_get_version
-lvm_init
-lvm_quit
-lvm_config_reload
-lvm_config_override
-lvm_errno
-lvm_errmsg
-lvm_scan
-lvm_list_vg_names
-lvm_list_vg_uuids
-lvm_vgname_from_pvid
-lvm_vgname_from_device
-lvm_vg_open
-lvm_vg_create
-lvm_vg_list_lvs
-lvm_vg_list_pvs
-lvm_vg_write
-lvm_vg_remove
-lvm_vg_close
-lvm_vg_extend
-lvm_vg_reduce
-lvm_vg_add_tag
-lvm_vg_remove_tag
-lvm_vg_set_extent_size
-lvm_vg_is_clustered
-lvm_vg_is_exported
-lvm_vg_is_partial
-lvm_vg_get_seqno
-lvm_vg_get_uuid
-lvm_vg_get_name
-lvm_vg_get_size
-lvm_vg_get_free_size
-lvm_vg_get_extent_size
-lvm_vg_get_extent_count
-lvm_vg_get_free_extent_count
-lvm_vg_get_pv_count
-lvm_vg_get_max_pv
-lvm_vg_get_max_lv
-lvm_vg_get_tags
-lvm_vg_create_lv_linear
-lvm_lv_activate
-lvm_lv_deactivate
-lvm_vg_remove_lv
-lvm_lv_get_uuid
-lvm_lv_get_name
-lvm_lv_get_size
-lvm_lv_is_active
-lvm_lv_is_suspended
-lvm_lv_add_tag
-lvm_lv_remove_tag
-lvm_lv_get_tags
-lvm_lv_resize
-lvm_pv_get_uuid
-lvm_pv_get_name
-lvm_pv_get_mda_count
-lvm_pv_get_dev_size
-lvm_pv_get_size
-lvm_pv_get_free
-lvm_pv_resize
--- LVM2/liblvm/Makefile.in	2010/06/25 12:19:55	1.24
+++ LVM2/liblvm/Makefile.in	2010/06/25 18:17:39	1.25
@@ -34,6 +34,9 @@
 
 CLEAN_TARGETS += liblvm.cflow $(LIB_NAME).a
 
+EXPORTED_HEADER = $(srcdir)/lvm2app.h
+EXPORTED_FN_PREFIX = lvm
+
 include $(top_builddir)/make.tmpl
 
 LIBS += $(LVMINTERNAL_LIBS) -ldevmapper
@@ -75,8 +78,4 @@
 
 cflow: liblvm.cflow
 
-.exported_symbols_new: $(srcdir)/lvm2app.h
-	$(CPP) -P $< | \
-	$(SED) -ne '/^(typedef|})/!s/.*[ \*]\(lvm_[a-z_]*\)(.*/\1/p' > $@
-
 DISTCLEAN_TARGETS += $(LIB_NAME).pc


