From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 May 2015 14:48:30 +0000 (UTC)
Subject: master - libdm: new dm_task_get_info with internal_suspend
Message-ID: <20150515144830.26C066130F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=797c18d543947f4c2777b4dcf3ceff57cb55352b
Commit:        797c18d543947f4c2777b4dcf3ceff57cb55352b
Parent:        3f10dfd6c79e05de89a9ef09bd92239ec1681b13
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 15 15:29:46 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 15 16:48:22 2015 +0200

libdm: new dm_task_get_info with internal_suspend

Introduce new implmentation of dm_task_get_info() function
with support for reading internal_suspend.
.
This time it is done in a 'versioned' way.

We keep the old fashion dm_task_get_info(Base) to implement
the old behavior of 1.02.95 libdm code.

libdm version 1.02.96 introduced 'macro' wrapper
dm_task_get_info_with_deferred_remove with new implementation
of dm_task_get_info() - we cannot do anything else then to
provide compatible version of this symbol.

Now in version 1.02.97 we add new versioned implementation of
dm_task_get_info(DM_1_02_97) symbol.

This has the effect that i.e. rpm build will finaly resolve proper
dependency on a new symbol - so it will be no longer possible,
to build a new binary and use old library
(rpm -q --provides will show libdevmapper.so.1.02(DM_1_02_97)(64bit))

Also the history is now tracked. If a new function is added (or
reimplemented), it needs to be placed in proper file,
so it could be exported with right versioning symbol.
File .exported_symbols.Base should and any existing older DM
should be treated as read-only after a release.

Also - only libdm has been currently enhanced with versioned .Base
file, as soon as other libs (liblvm, libdevmapper-event) needs changes
they should also get their exported symbol files - meanwhile
make.tmpl handles both cases.
---
 WHATS_NEW_DM                       |    2 +
 lib/misc/lib.h                     |   11 ++
 libdm/.exported_symbols            |    2 +-
 libdm/.exported_symbols.Base       |  287 ++++++++++++++++++++++++++++++++++++
 libdm/.exported_symbols.DM_1_02_97 |    1 +
 libdm/ioctl/libdm-iface.c          |   36 ++++-
 libdm/libdevmapper.h               |    3 +-
 make.tmpl.in                       |   21 +++-
 8 files changed, 354 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 4288899..cdea8c2 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,7 @@
 Version 1.02.97 - 
 ==============================
+  New dm_task_get_info(DM_1_02_97) supports internal_suspend state.
+  New symbols are versioned and comes with versioned symbol name (DM_1_02_97).
 
 Version 1.02.96 - 2nd May 2015
 ==============================
diff --git a/lib/misc/lib.h b/lib/misc/lib.h
index 3a35c22..63e58d0 100644
--- a/lib/misc/lib.h
+++ b/lib/misc/lib.h
@@ -30,6 +30,17 @@
 #define PRIptrdiff_t "td"
 #define PRIpid_t PRId32
 
+#if defined(__GNUC__)
+#define DM_EXPORTED_SYMBOL(func, ver) \
+	__asm__(".symver " #func "_v" #ver ", " #func "@@DM_" #ver )
+#define DM_EXPORTED_SYMBOL_BASE(func) \
+	__asm__(".symver " #func "_base, " #func "@Base" )
+#else
+#define DM_EXPORTED_SYMBOL(func, ver)
+#define DM_EXPORTED_SYMBOL_BASE(func)
+#endif
+
+
 #include "intl.h"
 #include "libdevmapper.h"
 #include "util.h"
diff --git a/libdm/.exported_symbols b/libdm/.exported_symbols
index 5bacc26..2b85343 100644
--- a/libdm/.exported_symbols
+++ b/libdm/.exported_symbols
@@ -1,3 +1,3 @@
 dm_log
 dm_log_with_errno
-dm_task_get_info
+dm_task_get_info_with_deferred_remove
diff --git a/libdm/.exported_symbols.Base b/libdm/.exported_symbols.Base
new file mode 100644
index 0000000..865a6a8
--- /dev/null
+++ b/libdm/.exported_symbols.Base
@@ -0,0 +1,287 @@
+dm_asprintf
+dm_basename
+dm_bit_and
+dm_bit_get_first
+dm_bit_get_next
+dm_bitset_create
+dm_bitset_destroy
+dm_bitset_equal
+dm_bit_union
+dm_bounds_check_debug
+dm_build_dm_name
+dm_build_dm_uuid
+dm_config_clone_node
+dm_config_clone_node_with_mem
+dm_config_create
+dm_config_create_node
+dm_config_create_value
+dm_config_destroy
+dm_config_find_bool
+dm_config_find_float
+dm_config_find_int
+dm_config_find_int64
+dm_config_find_node
+dm_config_find_str
+dm_config_find_str_allow_empty
+dm_config_flatten
+dm_config_from_string
+dm_config_get_custom
+dm_config_get_list
+dm_config_get_section
+dm_config_get_str
+dm_config_get_uint32
+dm_config_get_uint64
+dm_config_has_node
+dm_config_insert_cascaded_tree
+dm_config_maybe_section
+dm_config_memory
+dm_config_parent_name
+dm_config_parse
+dm_config_remove_cascaded_tree
+dm_config_remove_node
+dm_config_set_custom
+dm_config_tree_find_bool
+dm_config_tree_find_float
+dm_config_tree_find_int
+dm_config_tree_find_int64
+dm_config_tree_find_node
+dm_config_tree_find_str
+dm_config_tree_find_str_allow_empty
+dm_config_value_is_bool
+dm_config_write_node
+dm_config_write_node_out
+dm_config_write_one_node
+dm_config_write_one_node_out
+dm_cookie_supported
+dm_count_chars
+dm_create_dir
+dm_create_lockfile
+dm_daemon_is_running
+dm_device_get_name
+dm_device_has_holders
+dm_device_has_mounted_fs
+dm_dir
+dm_driver_version
+dm_dump_memory_debug
+dm_escaped_len
+dm_escape_double_quotes
+dm_fclose
+dm_format_dev
+dm_free_aux
+dm_get_library_version
+dm_get_name_mangling_mode
+dm_get_next_target
+dm_get_status_cache
+dm_get_status_raid
+dm_get_status_snapshot
+dm_get_status_thin
+dm_get_status_thin_pool
+dm_get_suspended_counter
+dm_hash_create
+dm_hash_destroy
+dm_hash_get_data
+dm_hash_get_first
+dm_hash_get_key
+dm_hash_get_next
+dm_hash_get_num_entries
+dm_hash_insert
+dm_hash_insert_binary
+dm_hash_iter
+dm_hash_lookup
+dm_hash_lookup_binary
+dm_hash_remove
+dm_hash_remove_binary
+dm_hash_wipe
+dm_is_dm_major
+dm_is_empty_dir
+dm_lib_exit
+dm_lib_init
+dm_lib_release
+dm_list_add
+dm_list_add_h
+dm_list_del
+dm_list_empty
+dm_list_end
+dm_list_first
+dm_list_init
+dm_list_last
+dm_list_move
+dm_list_next
+dm_list_prev
+dm_list_size
+dm_list_splice
+dm_list_start
+dm_log
+dm_log_init
+dm_log_init_verbose
+dm_log_is_non_default
+dm_log_with_errno
+dm_log_with_errno_init
+dm_make_percent
+dm_malloc_aux
+dm_malloc_aux_debug
+dm_mknodes
+dm_mountinfo_read
+dm_percent_to_float
+dm_pool_abandon_object
+dm_pool_alloc
+dm_pool_alloc_aligned
+dm_pool_begin_object
+dm_pool_create
+dm_pool_destroy
+dm_pool_empty
+dm_pool_end_object
+dm_pool_free
+dm_pool_grow_object
+dm_pool_lock
+dm_pool_locked
+dm_pool_strdup
+dm_pool_strndup
+dm_pool_unlock
+dm_pool_zalloc
+dm_prepare_selinux_context
+dm_realloc_aux
+dm_regex_create
+dm_regex_fingerprint
+dm_regex_match
+dm_report_compact_fields
+dm_report_field_int
+dm_report_field_int32
+dm_report_field_percent
+dm_report_field_set_value
+dm_report_field_string
+dm_report_field_string_list
+dm_report_field_string_list_unsorted
+dm_report_field_uint32
+dm_report_field_uint64
+dm_report_free
+dm_report_init
+dm_report_init_with_selection
+dm_report_object
+dm_report_object_is_selected
+dm_report_output
+dm_report_set_output_field_name_prefix
+dm_set_dev_dir
+dm_set_name_mangling_mode
+dm_set_selinux_context
+dm_set_sysfs_dir
+dm_set_uuid_prefix
+dm_snprintf
+dm_split_lvm_name
+dm_split_words
+dm_strdup_aux
+dm_strncpy
+dm_sysfs_dir
+dm_task_add_target
+dm_task_create
+dm_task_deferred_remove
+dm_task_destroy
+dm_task_enable_checks
+dm_task_get_deps
+dm_task_get_driver_version
+dm_task_get_info
+dm_task_get_info_with_deferred_remove
+dm_task_get_message_response
+dm_task_get_name
+dm_task_get_name_mangled
+dm_task_get_names
+dm_task_get_name_unmangled
+dm_task_get_read_ahead
+dm_task_get_uuid
+dm_task_get_uuid_mangled
+dm_task_get_uuid_unmangled
+dm_task_get_versions
+dm_task_no_flush
+dm_task_no_open_count
+dm_task_query_inactive_table
+dm_task_retry_remove
+dm_task_run
+dm_task_secure_data
+dm_task_set_add_node
+dm_task_set_cookie
+dm_task_set_event_nr
+dm_task_set_geometry
+dm_task_set_gid
+dm_task_set_major
+dm_task_set_major_minor
+dm_task_set_message
+dm_task_set_minor
+dm_task_set_mode
+dm_task_set_name
+dm_task_set_newname
+dm_task_set_newuuid
+dm_task_set_read_ahead
+dm_task_set_ro
+dm_task_set_sector
+dm_task_set_uid
+dm_task_set_uuid
+dm_task_skip_lockfs
+dm_task_suppress_identical_reload
+dm_task_update_nodes
+dm_tree_activate_children
+dm_tree_add_dev
+dm_tree_add_dev_with_udev_flags
+dm_tree_add_new_dev
+dm_tree_add_new_dev_with_udev_flags
+dm_tree_create
+dm_tree_deactivate_children
+dm_tree_find_node
+dm_tree_find_node_by_uuid
+dm_tree_free
+dm_tree_get_cookie
+dm_tree_children_use_uuid
+dm_tree_next_child
+dm_tree_node_add_cache_target
+dm_tree_node_add_crypt_target
+dm_tree_node_add_error_target
+dm_tree_node_add_linear_target
+dm_tree_node_add_mirror_target
+dm_tree_node_add_mirror_target_log
+dm_tree_node_add_null_area
+dm_tree_node_add_raid_target
+dm_tree_node_add_raid_target_with_params
+dm_tree_node_add_replicator_dev_target
+dm_tree_node_add_replicator_target
+dm_tree_node_add_snapshot_merge_target
+dm_tree_node_add_snapshot_origin_target
+dm_tree_node_add_snapshot_target
+dm_tree_node_add_striped_target
+dm_tree_node_add_target_area
+dm_tree_node_add_thin_pool_message
+dm_tree_node_add_thin_pool_target
+dm_tree_node_add_thin_target
+dm_tree_node_add_zero_target
+dm_tree_node_get_context
+dm_tree_node_get_info
+dm_tree_node_get_name
+dm_tree_node_get_uuid
+dm_tree_node_num_children
+dm_tree_node_set_callback
+dm_tree_node_set_presuspend_node
+dm_tree_node_set_read_ahead
+dm_tree_node_set_thin_external_origin
+dm_tree_node_set_thin_pool_discard
+dm_tree_node_set_thin_pool_error_if_no_space
+dm_tree_node_set_udev_flags
+dm_tree_node_size_changed
+dm_tree_preload_children
+dm_tree_retry_remove
+dm_tree_set_cookie
+dm_tree_set_optional_uuid_suffixes
+dm_tree_skip_lockfs
+dm_tree_suspend_children
+dm_tree_use_no_flush_suspend
+dm_udev_complete
+dm_udev_create_cookie
+dm_udev_get_checking
+dm_udev_get_sync_support
+dm_udev_set_checking
+dm_udev_set_sync_support
+dm_udev_wait
+dm_unescape_colons_and_at_signs
+dm_unescape_double_quotes
+dm_units_to_factor
+dm_uuid_prefix
+dm_vasprintf
+dm_zalloc_aux
+dm_zalloc_aux_debug
diff --git a/libdm/.exported_symbols.DM_1_02_97 b/libdm/.exported_symbols.DM_1_02_97
new file mode 100644
index 0000000..dcc513a
--- /dev/null
+++ b/libdm/.exported_symbols.DM_1_02_97
@@ -0,0 +1 @@
+dm_task_get_info
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 298723e..face593 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -666,7 +666,13 @@ int dm_format_dev(char *buf, int bufsize, uint32_t dev_major,
 	return 1;
 }
 
+#if defined(__GNUC__)
+int dm_task_get_info_v1_02_97(struct dm_task *dmt, struct dm_info *info);
+DM_EXPORTED_SYMBOL(dm_task_get_info, 1_02_97);
+int dm_task_get_info_v1_02_97(struct dm_task *dmt, struct dm_info *info)
+#else
 int dm_task_get_info(struct dm_task *dmt, struct dm_info *info)
+#endif
 {
 	if (!dmt->dmi.v4)
 		return 0;
@@ -683,6 +689,7 @@ int dm_task_get_info(struct dm_task *dmt, struct dm_info *info)
 	info->inactive_table = dmt->dmi.v4->flags & DM_INACTIVE_PRESENT_FLAG ?
 	    1 : 0;
 	info->deferred_remove = dmt->dmi.v4->flags & DM_DEFERRED_REMOVE;
+	info->internal_suspend = (dmt->dmi.v4->flags & DM_INTERNAL_SUSPEND_FLAG) ? 1 : 0;
 	info->target_count = dmt->dmi.v4->target_count;
 	info->open_count = dmt->dmi.v4->open_count;
 	info->event_nr = dmt->dmi.v4->event_nr;
@@ -2061,6 +2068,12 @@ void dm_lib_exit(void)
 	_version_checked = 0;
 }
 
+#if defined(__GNUC__)
+/*
+ * Maintain binary backward compatibility.
+ * Version script mechanism works with 'gcc' compatible compilers only.
+ */
+
 /*
  * This following code is here to retain ABI compatibility after adding
  * the field deferred_remove to struct dm_info in version 1.02.89.
@@ -2076,16 +2089,31 @@ void dm_lib_exit(void)
  * N.B. Keep this function at the end of the file to make sure that
  * no code in this file accidentally calls it.
  */
-#undef dm_task_get_info
-int dm_task_get_info(struct dm_task *dmt, struct dm_info *info);
-int dm_task_get_info(struct dm_task *dmt, struct dm_info *info)
+
+int dm_task_get_info_base(struct dm_task *dmt, struct dm_info *info);
+DM_EXPORTED_SYMBOL_BASE(dm_task_get_info);
+int dm_task_get_info_base(struct dm_task *dmt, struct dm_info *info)
 {
 	struct dm_info new_info;
 
-	if (!dm_task_get_info_with_deferred_remove(dmt, &new_info))
+	if (!dm_task_get_info_v1_02_97(dmt, &new_info))
 		return 0;
 
 	memcpy(info, &new_info, offsetof(struct dm_info, deferred_remove));
 
 	return 1;
 }
+
+int dm_task_get_info_with_deferred_remove(struct dm_task *dmt, struct dm_info *info);
+int dm_task_get_info_with_deferred_remove(struct dm_task *dmt, struct dm_info *info)
+{
+	struct dm_info new_info;
+
+	if (!dm_task_get_info_v1_02_97(dmt, &new_info))
+		return 0;
+
+	memcpy(info, &new_info, offsetof(struct dm_info, internal_suspend));
+
+	return 1;
+}
+#endif
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 309e63f..8295e3c 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -151,6 +151,7 @@ struct dm_info {
 	int32_t target_count;
 
 	int deferred_remove;
+	int internal_suspend;
 };
 
 struct dm_deps {
@@ -174,8 +175,6 @@ struct dm_versions {
 
 int dm_get_library_version(char *version, size_t size);
 int dm_task_get_driver_version(struct dm_task *dmt, char *version, size_t size);
-
-#define dm_task_get_info dm_task_get_info_with_deferred_remove
 int dm_task_get_info(struct dm_task *dmt, struct dm_info *dmi);
 
 /*
diff --git a/make.tmpl.in b/make.tmpl.in
index 4311490..33d79c2 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -485,7 +485,7 @@ distclean: cleandir $(SUBDIRS.distclean)
 	test -z "$(DISTCLEAN_DIRS)" || $(RM) -r $(DISTCLEAN_DIRS)
 	$(RM) $(DISTCLEAN_TARGETS) Makefile
 
-.exported_symbols_generated: $(EXPORTED_HEADER) .exported_symbols
+.exported_symbols_generated: $(EXPORTED_HEADER) .exported_symbols $(DEPS)
 	set -e; \
 	( cat $(srcdir)/.exported_symbols; \
 	  if test x$(EXPORTED_HEADER) != x; then \
@@ -494,11 +494,28 @@ distclean: cleandir $(SUBDIRS.distclean)
 	  fi \
 	) > $@
 
+EXPORTED_UC := $(shell echo $(EXPORTED_FN_PREFIX) | tr '[a-z]' '[A-Z]')
+EXPORTED_FILES := $(wildcard $(srcdir)/.exported_symbols.Base $(srcdir)/.exported_symbols.$(EXPORTED_UC)_[0-9_]*[0-9])
+
+ifeq (0,$(words $(EXPORTED_FILES)))
 .export.sym: .exported_symbols_generated
 	set -e; (echo "Base {"; echo "	global:"; \
-		 sed "s/^/		/;s/$$/;/" < $<; \
+		 $(SED) "s/^/		/;s/$$/;/" < $<; \
 		 echo "	local:"; echo "		*;"; echo "};") > $@
 
+else
+.export.sym: .exported_symbols_generated $(EXPORTED_FILES)
+	set -e; \
+	R=$(shell sort $^ | uniq -u);\
+	test -z "$$R" || { echo "Mismatch between symbols in shared library and lists in .exported_symbols.* files: $$R"; false; } ;\
+	(for i in $(EXPORTED_FILES) ; do\
+		echo "$${i##*.} {"; echo "	global:";\
+		$(SED) "s/^/		/;s/$$/;/" < $$i;\
+		test "$$i" = Base && { echo "	local:"; echo "		*;"; };\
+		echo "};";\
+	done ) > $@
+endif
+
 ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov \
  help check check_local check_cluster check_lvmetad check_lvmpolld))
     ifdef SOURCES


