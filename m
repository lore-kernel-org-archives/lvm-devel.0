From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 13 Nov 2017 16:25:04 -0500
Subject: master - log: Improve various device-related messages
Message-ID: <201711132125.vADLP4nw031665@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6bf0f04ae2cb4e2c33a9836125a41e9e6b21e4d7
Commit:        6bf0f04ae2cb4e2c33a9836125a41e9e6b21e4d7
Parent:        598fcccf458010dac5d9e319db943629e15d5b16
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Nov 13 14:43:32 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Nov 13 19:45:33 2017 +0000

log: Improve various device-related messages

- Use 'lvmcache' consistently instead of 'metadata cache'
- Always use 5 characters for source line number
- Remember to convert uuids into printable form
- Use <no name> rather than (null) when VG has no name.
---
 lib/cache/lvmcache.c            |   10 +++++-----
 lib/device/dev-cache.c          |    6 +++---
 lib/device/dev-ext.c            |   14 ++++++--------
 lib/device/dev-io.c             |   12 +++++-------
 lib/filters/filter-internal.c   |    2 +-
 lib/filters/filter-persistent.c |    1 +
 lib/log/log.c                   |    8 ++++----
 lib/metadata/metadata.c         |   10 ++++++++--
 lib/metadata/vg.c               |    4 ++--
 tools/lvmcmdline.c              |    8 ++++----
 tools/toollib.c                 |    6 +++---
 11 files changed, 42 insertions(+), 39 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index c51e157..5d4732c 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -154,7 +154,7 @@ static void _free_cached_vgmetadata(struct lvmcache_vginfo *vginfo)
 		vginfo->cft = NULL;
 	}
 
-	log_debug_cache("Metadata cache: VG %s wiped.", vginfo->vgname);
+	log_debug_cache("lvmcache: VG %s wiped.", vginfo->vgname);
 
 	release_vg(vginfo->cached_vg);
 }
@@ -197,7 +197,7 @@ static void _store_metadata(struct volume_group *vg, unsigned precommitted)
 		return;
 	}
 
-	log_debug_cache("Metadata cache: VG %s (%s) stored (%" PRIsize_t " bytes%s).",
+	log_debug_cache("lvmcache: VG %s (%s) stored (%" PRIsize_t " bytes%s).",
 			vginfo->vgname, uuid, size,
 			precommitted ? ", precommitted" : "");
 }
@@ -289,7 +289,7 @@ void lvmcache_commit_metadata(const char *vgname)
 		return;
 
 	if (vginfo->precommitted) {
-		log_debug_cache("Precommitted metadata cache: VG %s upgraded to committed.",
+		log_debug_cache("lvmcache: Upgraded pre-committed VG %s metadata to committed.",
 				vginfo->vgname);
 		vginfo->precommitted = 0;
 	}
@@ -616,7 +616,7 @@ struct lvmcache_vginfo *lvmcache_vginfo_from_vgid(const char *vgid)
 	id[ID_LEN] = '\0';
 
 	if (!(vginfo = dm_hash_lookup(_vgid_hash, id))) {
-		log_debug_cache("Metadata cache has no info for vgid \"%s\"", id);
+		log_debug_cache("lvmcache has no info for vgid \"%s\"", id);
 		return NULL;
 	}
 
@@ -1870,7 +1870,7 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 				vginfo->vgid[0] ? vginfo->vgid : "",
 				vginfo->vgid[0] ? ")" : "", mdabuf);
 	} else
-		log_debug_cache("lvmcache initialised VG %s.", vgname);
+		log_debug_cache("lvmcache: Initialised VG %s.", vgname);
 
 	return 1;
 }
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index dd12da1..2cd38f4 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -708,7 +708,7 @@ static int _insert_dev(const char *path, dev_t d)
 
 	if (dm_hash_lookup(_cache.names, path) == dev) {
 		/* Hash already has matching entry present */
-		log_debug("Path already cached %s.", path);
+		log_debug("%s: Path already cached.", path);
 		return 1;
 	}
 
@@ -1423,7 +1423,7 @@ struct device *dev_cache_get(const char *name, struct dev_filter *f)
 	if (!d || (f && !(d->flags & DEV_REGULAR) && !(f->passes_filter(f, d))))
 		return NULL;
 
-	log_debug_devs("Using %s", dev_name(d));
+	log_debug_devs("%s: Using device (%d:%d)", dev_name(d), (int) MAJOR(d->dev), (int) MINOR(d->dev));
 	return d;
 }
 
@@ -1533,7 +1533,7 @@ struct device *dev_iter_get(struct dev_iter *iter)
 		struct device *d = _iter_next(iter);
 		if (!iter->filter || (d->flags & DEV_REGULAR) ||
 		    iter->filter->passes_filter(iter->filter, d)) {
-			log_debug_devs("Using %s", dev_name(d));
+			log_debug_devs("%s: Using device (%d:%d)", dev_name(d), (int) MAJOR(d->dev), (int) MINOR(d->dev));
 			return d;
 		}
 	}
diff --git a/lib/device/dev-ext.c b/lib/device/dev-ext.c
index 0cc8279..0c3b435 100644
--- a/lib/device/dev-ext.c
+++ b/lib/device/dev-ext.c
@@ -100,8 +100,6 @@ const char *dev_ext_name(struct device *dev)
 	return _ext_registry[dev->ext.src].name;
 }
 
-static const char *_ext_attached_msg = "External handle attached to device";
-
 struct dev_ext *dev_ext_get(struct device *dev)
 {
 	struct dev_ext *ext;
@@ -110,10 +108,10 @@ struct dev_ext *dev_ext_get(struct device *dev)
 	handle_ptr = dev->ext.handle;
 
 	if (!(ext = _ext_registry[dev->ext.src].dev_ext_get(dev)))
-		log_error("Failed to get external handle for device %s [%s].",
+		log_error("%s: Failed to get external handle [%s].",
 			   dev_name(dev), dev_ext_name(dev));
 	else if (handle_ptr != dev->ext.handle)
-		log_debug_devs("%s %s [%s:%p]", _ext_attached_msg, dev_name(dev),
+		log_debug_devs("%s: External handle [%s:%p] attached", dev_name(dev),
 				dev_ext_name(dev), dev->ext.handle);
 
 	return ext;
@@ -131,10 +129,10 @@ int dev_ext_release(struct device *dev)
 	handle_ptr = dev->ext.handle;
 
 	if (!(r = _ext_registry[dev->ext.src].dev_ext_release(dev)))
-		log_error("Failed to release external handle for device %s [%s:%p].",
+		log_error("%s: Failed to release external handle [%s:%p]",
 			  dev_name(dev), dev_ext_name(dev), dev->ext.handle);
 	else
-		log_debug_devs("External handle detached from device %s [%s:%p]",
+		log_debug_devs("%s: External handle [%s:%p] detached",
 				dev_name(dev), dev_ext_name(dev), handle_ptr);
 
 	return r;
@@ -143,7 +141,7 @@ int dev_ext_release(struct device *dev)
 int dev_ext_enable(struct device *dev, dev_ext_t src)
 {
 	if (dev->ext.enabled && (dev->ext.src != src) && !dev_ext_release(dev)) {
-		log_error("Failed to enable external handle for device %s [%s].",
+		log_error("%s: Failed to enable external handle [%s].",
 			   dev_name(dev), _ext_registry[src].name); 
 		return 0;
 	}
@@ -160,7 +158,7 @@ int dev_ext_disable(struct device *dev)
 		return 1;
 
 	if (!dev_ext_release(dev)) {
-		log_error("Failed to disable external handle for device %s [%s].",
+		log_error("%s: Failed to disable external handle [%s].",
 			   dev_name(dev), dev_ext_name(dev));
 		return 0;
 	}
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 519b5c7..328ec30 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -142,7 +142,7 @@ int dev_get_block_size(struct device *dev, unsigned int *physical_block_size, un
 			r = 0;
 			goto out;
 		}
-		log_debug_devs("%s: block size is %u bytes", name, dev->block_size);
+		log_debug_devs("%s: Block size is %u bytes", name, dev->block_size);
 	}
 
 #ifdef BLKPBSZGET
@@ -153,7 +153,7 @@ int dev_get_block_size(struct device *dev, unsigned int *physical_block_size, un
 			r = 0;
 			goto out;
 		}
-		log_debug_devs("%s: physical block size is %u bytes", name, dev->phys_block_size);
+		log_debug_devs("%s: Physical block size is %u bytes", name, dev->phys_block_size);
 	}
 #elif defined (BLKSSZGET)
 	/* if we can't get physical block size, just use logical block size instead */
@@ -163,15 +163,13 @@ int dev_get_block_size(struct device *dev, unsigned int *physical_block_size, un
 			r = 0;
 			goto out;
 		}
-		log_debug_devs("%s: physical block size can't be determined, using logical "
-			       "block size of %u bytes", name, dev->phys_block_size);
+		log_debug_devs("%s: Physical block size can't be determined: Using logical block size of %u bytes", name, dev->phys_block_size);
 	}
 #else
 	/* if even BLKSSZGET is not available, use default 512b */
 	if (dev->phys_block_size == -1) {
 		dev->phys_block_size = 512;
-		log_debug_devs("%s: physical block size can't be determined, using block "
-			       "size of %u bytes instead", name, dev->phys_block_size);
+		log_debug_devs("%s: Physical block size can't be determined: Using block size of %u bytes instead", name, dev->phys_block_size);
 	}
 #endif
 
@@ -464,7 +462,7 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 		}
 
 		if (dev->open_count && !need_excl) {
-			log_debug_devs("%s already opened read-only. Upgrading "
+			log_debug_devs("%s: Already opened read-only. Upgrading "
 				       "to read-write.", dev_name(dev));
 			dev->open_count++;
 		}
diff --git a/lib/filters/filter-internal.c b/lib/filters/filter-internal.c
index 1a58a37..cdaee4e 100644
--- a/lib/filters/filter-internal.c
+++ b/lib/filters/filter-internal.c
@@ -74,7 +74,7 @@ struct dev_filter *internal_filter_create(void)
 	f->destroy = _destroy;
 	f->use_count = 0;
 
-	log_debug_devs("internal filter initialised.");
+	log_debug_devs("Internal filter initialised.");
 
 	return f;
 }
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 4e8161e..5bc0861 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -119,6 +119,7 @@ int persistent_filter_load(struct dev_filter *f, struct dm_config_tree **cft_out
 	if (!config_file_read(cft))
 		goto_out;
 
+	log_debug_devs("Loading persistent filter cache from %s", pf->file);
 	_read_array(pf, cft, "persistent_filter_cache/valid_devices",
 		    PF_GOOD_DEVICE);
 	/* We don't gain anything by holding invalid devices */
diff --git a/lib/log/log.c b/lib/log/log.c
index c0789b4..208959b 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -594,7 +594,7 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
       log_it:
 	if (!logged_via_report && ((verbose_level() >= level) && !_log_suppress)) {
 		if (verbose_level() > _LOG_DEBUG) {
-			(void) dm_snprintf(buf, sizeof(buf), "#%s:%d ",
+			(void) dm_snprintf(buf, sizeof(buf), "#%s:%-5d ",
 					   file, line);
 		} else
 			buf[0] = '\0';
@@ -639,7 +639,7 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
 	}
 
 	if (_log_to_file && (_log_while_suspended || !critical_section())) {
-		fprintf(_log_file, "%s:%d %s%s", file, line, log_command_name(),
+		fprintf(_log_file, "%s:%-5d %s%s", file, line, log_command_name(),
 			_msg_prefix);
 
 		va_copy(ap, orig_ap);
@@ -647,7 +647,7 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
 		va_end(ap);
 
 		if (_log_file_max_lines && ++_log_file_lines >= _log_file_max_lines) {
-			fprintf(_log_file, "\n%s:%d %sAborting. Command has reached limit "
+			fprintf(_log_file, "\n%s:%-5d %sAborting. Command has reached limit "
 				"for logged lines (LVM_LOG_FILE_MAX_LINES=" FMTu64 ").",
 				file, line, _msg_prefix,
 				_log_file_max_lines);
@@ -673,7 +673,7 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
 		memset(&buf, ' ', sizeof(buf));
 		bufused = 0;
 		if ((n = dm_snprintf(buf, sizeof(buf),
-				      "%s:%d %s%s", file, line, log_command_name(),
+				      "%s:%-5d %s%s", file, line, log_command_name(),
 				      _msg_prefix)) == -1)
 			goto done;
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b5acf07..d823ef2 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3797,12 +3797,18 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	struct dm_list *pvids;
 	struct pv_list *pvl;
 	struct dm_list all_pvs;
+	char uuid[64] __attribute__((aligned(8)));
+
 	unsigned seqno = 0;
 	int reappeared = 0;
 	struct cached_vg_fmtdata *vg_fmtdata = NULL;	/* Additional format-specific data about the vg */
 	unsigned use_previous_vg;
 
-	log_very_verbose("Reading VG %s %.32s", vgname ?: "<no name>", vgid ?: "<no vgid>");
+	uuid[0] = '\0';
+	if (vgid && !id_write_format((const struct id*)vgid, uuid, sizeof(uuid)))
+		stack;
+
+	log_very_verbose("Reading VG %s %s", vgname ?: "<no name>", vgid ? uuid : "<no vgid>");
 
 	if (is_orphan_vg(vgname)) {
 		if (use_precommitted) {
@@ -3879,7 +3885,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 
 	/* Now determine the correct vgname if none was supplied */
 	if (!vgname && !(vgname = lvmcache_vgname_from_vgid(cmd->mem, vgid))) {
-		log_debug_metadata("Cache did not find VG name from vgid %.32s", vgid);
+		log_debug_metadata("Cache did not find VG name from vgid %s", uuid);
 		return_NULL;
 	}
 
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 9f48a9b..f90ac82 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -71,7 +71,7 @@ struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 	dm_list_init(&vg->removed_historical_lvs);
 	dm_list_init(&vg->removed_pvs);
 
-	log_debug_mem("Allocated VG %s at %p.", vg->name, vg);
+	log_debug_mem("Allocated VG %s at %p.", vg->name ? : "<no name>", vg);
 
 	return vg;
 }
@@ -86,7 +86,7 @@ static void _free_vg(struct volume_group *vg)
 		return;
 	}
 
-	log_debug_mem("Freeing VG %s at %p.", vg->name, vg);
+	log_debug_mem("Freeing VG %s at %p.", vg->name ? : "<no name>", vg);
 
 	dm_hash_destroy(vg->hostnames);
 	dm_pool_destroy(vg->vgmem);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index ed73b8d..22f1c60 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1864,8 +1864,8 @@ out:
 		}
 	}
 
-	log_debug("Using command index %d id %s enum %d.",
-		  best_i, commands[best_i].command_id, commands[best_i].command_enum);
+	log_debug("Recognised command %s (id %d / enum %d).",
+		  commands[best_i].command_id, best_i, commands[best_i].command_enum);
 
 	return &commands[best_i];
 }
@@ -2873,9 +2873,9 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		goto_out;
 	init_dmeventd_monitor(monitoring);
 
-	log_debug("Processing: %s", cmd->cmd_line);
+	log_debug("Processing command: %s", cmd->cmd_line);
 	log_debug("Command pid: %d", getpid());
-	log_debug("system ID: %s", cmd->system_id ? : "");
+	log_debug("System ID: %s", cmd->system_id ? : "");
 
 #ifdef O_DIRECT_SUPPORT
 	log_debug("O_DIRECT will be used");
diff --git a/tools/toollib.c b/tools/toollib.c
index 2898525..9b88341 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1967,7 +1967,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 		    (!dm_list_empty(arg_tags) && str_list_match_list(arg_tags, &vg->tags, NULL))) &&
 		    select_match_vg(cmd, handle, vg) && _select_matches(handle)) {
 
-			log_very_verbose("Process single VG %s", vg_name);
+			log_very_verbose("Processing VG %s %s", vg_name, vg_uuid ? uuid : "");
 
 			ret = process_single_vg(cmd, vg_name, vg, handle);
 			_update_selection_result(handle, &whole_selected);
@@ -2231,7 +2231,7 @@ int process_each_vg(struct cmd_context *cmd,
 	 * . A VG name is specified which may refer to one
 	 *   of multiple VGs on the system with that name.
 	 */
-	log_debug("Get list of VGs on system");
+	log_very_verbose("Obtaining the complete list of VGs to process");
 
 	if (!get_vgnameids(cmd, &vgnameids_on_system, NULL, include_internal)) {
 		ret_max = ECMD_FAILED;
@@ -3733,7 +3733,7 @@ int process_each_lv(struct cmd_context *cmd,
 	 * . A VG name is specified which may refer to one
 	 *   of multiple VGs on the system with that name.
 	 */
-	log_debug("Get list of VGs on system");
+	log_very_verbose("Obtaining the complete list of VGs before processing their LVs");
 
 	if (!get_vgnameids(cmd, &vgnameids_on_system, NULL, 0)) {
 		ret_max = ECMD_FAILED;


