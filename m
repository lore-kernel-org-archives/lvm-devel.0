From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 20 Jul 2017 06:19:01 -0400
Subject: master - tidy: prefer not using else after return
Message-ID: <201707201019.v6KAJ1UE016492@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0bf836aa14f98eb83969a6e81695a024f56a5eb5
Commit:        0bf836aa14f98eb83969a6e81695a024f56a5eb5
Parent:        0d0a3397c22b9d5342584299acd814f6c8221c18
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 19 16:16:12 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 20 11:18:29 2017 +0200

tidy: prefer not using else after return

clang-tidy: avoid using  'else' after return - give more readable code,
and also saves indention level.
---
 daemons/dmeventd/dmeventd.c           |    3 +-
 daemons/dmeventd/libdevmapper-event.c |   17 +++++-----
 lib/activate/activate.c               |   12 +++++--
 lib/activate/dev_manager.c            |    9 +++--
 lib/activate/fs.c                     |   20 ++++++-----
 lib/cache/lvmetad.c                   |   13 ++++---
 lib/config/config.c                   |    3 +-
 lib/device/dev-cache.c                |   10 +++---
 lib/device/dev-io.c                   |    4 +-
 lib/device/dev-type.c                 |   24 +++++++-------
 lib/filters/filter-sysfs.c            |    5 ++-
 lib/format_text/format-text.c         |   21 ++++++------
 lib/locking/cluster_locking.c         |    9 +++--
 lib/locking/locking.c                 |   10 +++--
 lib/locking/lvmlockd.c                |   43 +++++++++++++------------
 lib/metadata/lv.c                     |   40 +++++++++++------------
 lib/metadata/lv_manip.c               |   42 ++++++++++++++----------
 lib/metadata/metadata.c               |   14 +++++---
 lib/metadata/mirror.c                 |   12 +++++--
 lib/metadata/pv_manip.c               |    9 +++--
 lib/metadata/raid_manip.c             |   48 +++++++++++++++++++---------
 lib/replicator/replicator.c           |    4 ++-
 lib/report/report.c                   |   56 +++++++++++++++++---------------
 libdm/ioctl/libdm-iface.c             |   19 ++++++-----
 libdm/libdm-common.c                  |   13 +++----
 libdm/libdm-report.c                  |   10 +++--
 tools/dmsetup.c                       |    7 ++--
 tools/lvconvert.c                     |   17 ++++++----
 tools/lvcreate.c                      |    4 ++-
 tools/polldaemon.c                    |   33 ++++++++++---------
 tools/toollib.c                       |   14 +++++---
 tools/vgdisplay.c                     |   17 ++++++----
 32 files changed, 318 insertions(+), 244 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index a2883a1..3a92ab6 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -2252,7 +2252,8 @@ int main(int argc, char *argv[])
 					 "for %ld second(s), exiting.",
 					 (long) (time(NULL) - _idle_since));
 				break;
-			} else if (idle_exit_timeout) {
+			}
+			if (idle_exit_timeout) {
 				now = time(NULL);
 				if (now < _idle_since)
 					_idle_since = now; /* clock change? */
diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index b23b6c1..210e384 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -250,10 +250,9 @@ static int _daemon_read(struct dm_event_fifos *fifos,
 		if (ret < 0) {
 			if ((errno == EINTR) || (errno == EAGAIN))
 				continue;
-			else {
-				log_error("Unable to read from event server.");
-				return 0;
-			}
+
+			log_error("Unable to read from event server.");
+			return 0;
 		}
 
 		bytes += ret;
@@ -329,10 +328,9 @@ static int _daemon_write(struct dm_event_fifos *fifos,
 		if (ret < 0) {
 			if ((errno == EINTR) || (errno == EAGAIN))
 				continue;
-			else {
-				log_error("Unable to talk to event daemon.");
-				return 0;
-			}
+
+			log_error("Unable to talk to event daemon.");
+			return 0;
 		}
 
 		bytes += ret;
@@ -454,7 +452,8 @@ static int _start_daemon(char *dmeventd_path, struct dm_event_fifos *fifos)
 		if (close(fifos->client))
 			log_sys_debug("close", fifos->client_path);
 		return 1;
-	} else if (errno != ENXIO && errno != ENOENT)  {
+	}
+	if (errno != ENXIO && errno != ENOENT)  {
 		/* problem */
 		log_sys_error("open", fifos->client_path);
 		return 0;
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index d73e8b1..1bbd1b5 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -797,14 +797,18 @@ int lv_info_with_seg_status(struct cmd_context *cmd,
 				status->info.exists = 0; /* So pool LV is not active */
 		}
 		return 1;
-	} else if (lv_is_external_origin(lv)) {
+	}
+
+	if (lv_is_external_origin(lv)) {
 		if (!_lv_info(cmd, lv, 0, &status->info, NULL, NULL,
 			      with_open_count, with_read_ahead))
 			return_0;
 
 		(void) _lv_info(cmd, lv, 1, NULL, lv_seg, &status->seg_status, 0, 0);
 		return 1;
-	} else if (lv_is_origin(lv)) {
+	}
+
+	if (lv_is_origin(lv)) {
 		/* Query segment status for 'layered' (-real) device most of the time,
 		 * only for merging snapshot, query its progress.
 		 * TODO: single LV may need couple status to be exposed at once....
@@ -821,7 +825,9 @@ int lv_info_with_seg_status(struct cmd_context *cmd,
 			/* Grab STATUS from layered -real */
 			(void) _lv_info(cmd, lv, 1, NULL, lv_seg, &status->seg_status, 0, 0);
 		return 1;
-	} else if (lv_is_cow(lv)) {
+	}
+
+	if (lv_is_cow(lv)) {
 		if (lv_is_merging_cow(lv)) {
 			olv = origin_from_cow(lv);
 
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index daddfc8..8d96259 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1056,10 +1056,11 @@ static int _percent(struct dev_manager *dm, const char *name, const char *dlid,
 		if (_percent_run(dm, NULL, dlid, target_type, wait, lv, percent,
 				 event_nr, fail_if_percent_unsupported))
 			return 1;
-		else if (_original_uuid_format_check_required(dm->cmd) &&
-			 _percent_run(dm, NULL, dlid + sizeof(UUID_PREFIX) - 1,
-				      target_type, wait, lv, percent,
-				      event_nr, fail_if_percent_unsupported))
+
+		if (_original_uuid_format_check_required(dm->cmd) &&
+		    _percent_run(dm, NULL, dlid + sizeof(UUID_PREFIX) - 1,
+				 target_type, wait, lv, percent,
+				 event_nr, fail_if_percent_unsupported))
 			return 1;
 	}
 
diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index 2f455ba..a0b8bff 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -186,11 +186,11 @@ static int _mk_link(const char *dev_dir, const char *vg_name,
 			    !stat(lv_path, &buf)) {
 				if (buf_lp.st_rdev == buf.st_rdev)
 					return 1;
-				else
-					log_warn("Symlink %s that should have been "
-						 "created by udev does not have "
-						 "correct target. Falling back to "
-						 "direct link creation", lv_path);
+
+				log_warn("Symlink %s that should have been "
+					 "created by udev does not have "
+					 "correct target. Falling back to "
+					 "direct link creation", lv_path);
 			} else
 				log_warn("Symlink %s that should have been "
 					 "created by udev could not be checked "
@@ -239,7 +239,9 @@ static int _rm_link(const char *dev_dir, const char *vg_name,
 			return 1;
 		log_sys_error("lstat", lv_path);
 		return 0;
-	} else if (dm_udev_get_sync_support() && udev_checking() && check_udev)
+	}
+
+	if (dm_udev_get_sync_support() && udev_checking() && check_udev)
 		log_warn("The link %s should have been removed by udev "
 			 "but it is still present. Falling back to "
 			 "direct link removal.", lv_path);
@@ -478,9 +480,9 @@ int fs_rename_lv(const struct logical_volume *lv, const char *dev,
 			 _fs_op(FS_ADD, lv->vg->cmd->dev_dir, lv->vg->name,
 				lv->name, dev, "", lv->vg->cmd->current_settings.udev_rules));
 	}
-	else 
-		return _fs_op(FS_RENAME, lv->vg->cmd->dev_dir, lv->vg->name, lv->name,
-			      dev, old_lvname, lv->vg->cmd->current_settings.udev_rules);
+
+	return _fs_op(FS_RENAME, lv->vg->cmd->dev_dir, lv->vg->name, lv->name,
+		      dev, old_lvname, lv->vg->cmd->current_settings.udev_rules);
 }
 
 void fs_unlock(void)
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 5490675..2e0ee51 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -145,13 +145,14 @@ int lvmetad_connect(struct cmd_context *cmd)
 		_lvmetad_use = 1;
 		_lvmetad_cmd = cmd;
 		return 1;
-	} else {
-		log_debug_lvmetad("Failed to connect to lvmetad: %s", strerror(_lvmetad.error));
-		_lvmetad_connected = 0;
-		_lvmetad_use = 0;
-		_lvmetad_cmd = NULL;
-		return 0;
 	}
+
+	log_debug_lvmetad("Failed to connect to lvmetad: %s", strerror(_lvmetad.error));
+	_lvmetad_connected = 0;
+	_lvmetad_use = 0;
+	_lvmetad_cmd = NULL;
+
+	return 0;
 }
 
 int lvmetad_used(void)
diff --git a/lib/config/config.c b/lib/config/config.c
index daf5fa3..04dded7 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -481,7 +481,8 @@ int override_config_tree_from_profile(struct cmd_context *cmd,
 
 	if (profile->source == CONFIG_PROFILE_COMMAND)
 		return _override_config_tree_from_command_profile(cmd, profile);
-	else if (profile->source == CONFIG_PROFILE_METADATA)
+
+	if (profile->source == CONFIG_PROFILE_METADATA)
 		return _override_config_tree_from_metadata_profile(cmd, profile);
 
 	log_error(INTERNAL_ERROR "override_config_tree_from_profile: incorrect profile source type");
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 9a4dbc9..7802e45 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -320,8 +320,8 @@ static int _compare_paths(const char *path0, const char *path1)
 	/* ASCII comparison */
 	if (strcmp(path0, path1) < 0)
 		return 0;
-	else
-		return 1;
+
+	return 1;
 }
 
 static int _add_alias(struct device *dev, const char *path)
@@ -898,10 +898,10 @@ int dev_cache_index_devs(void)
 			if (errno == ENOENT) {
 				sysfs_has_dev_block = 0;
 				return 1;
-			} else {
-				log_sys_error("stat", path);
-				return 0;
 			}
+
+			log_sys_error("stat", path);
+			return 0;
 		}
 	} else if (!sysfs_has_dev_block)
 		return 1;
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index a9a2374..519b5c7 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -405,8 +405,8 @@ int dev_get_size(struct device *dev, uint64_t *size)
 
 	if ((dev->flags & DEV_REGULAR))
 		return _dev_get_size_file(dev, size);
-	else
-		return _dev_get_size_dev(dev, size);
+
+	return _dev_get_size_dev(dev, size);
 }
 
 int dev_get_read_ahead(struct device *dev, uint32_t *read_ahead)
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 325b66b..aa22e3b 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -615,38 +615,38 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 			if (force < DONT_PROMPT) {
 				log_error(MSG_FAILED_SIG_OFFSET, type, name);
 				return 0;
-			} else {
-				log_error("WARNING: " MSG_FAILED_SIG_OFFSET MSG_WIPING_SKIPPED, type, name);
-				return 2;
 			}
+
+			log_error("WARNING: " MSG_FAILED_SIG_OFFSET MSG_WIPING_SKIPPED, type, name);
+			return 2;
 		}
 		if (blkid_probe_lookup_value(probe, "SBMAGIC", &magic, &len)) {
 			if (force < DONT_PROMPT) {
 				log_error(MSG_FAILED_SIG_LENGTH, type, name);
 				return 0;
-			} else {
-				log_warn("WARNING: " MSG_FAILED_SIG_LENGTH MSG_WIPING_SKIPPED, type, name);
-				return 2;
 			}
+
+			log_warn("WARNING: " MSG_FAILED_SIG_LENGTH MSG_WIPING_SKIPPED, type, name);
+			return 2;
 		}
 	} else if (!blkid_probe_lookup_value(probe, "PTTYPE", &type, NULL)) {
 		if (blkid_probe_lookup_value(probe, "PTMAGIC_OFFSET", &offset, NULL)) {
 			if (force < DONT_PROMPT) {
 				log_error(MSG_FAILED_SIG_OFFSET, type, name);
 				return 0;
-			} else {
-				log_warn("WARNING: " MSG_FAILED_SIG_OFFSET MSG_WIPING_SKIPPED, type, name);
-				return 2;
 			}
+
+			log_warn("WARNING: " MSG_FAILED_SIG_OFFSET MSG_WIPING_SKIPPED, type, name);
+			return 2;
 		}
 		if (blkid_probe_lookup_value(probe, "PTMAGIC", &magic, &len)) {
 			if (force < DONT_PROMPT) {
 				log_error(MSG_FAILED_SIG_LENGTH, type, name);
 				return 0;
-			} else {
-				log_warn("WARNING: " MSG_FAILED_SIG_LENGTH MSG_WIPING_SKIPPED, type, name);
-				return 2;
 			}
+
+			log_warn("WARNING: " MSG_FAILED_SIG_LENGTH MSG_WIPING_SKIPPED, type, name);
+			return 2;
 		}
 		usage = "partition table";
 	} else
diff --git a/lib/filters/filter-sysfs.c b/lib/filters/filter-sysfs.c
index 6dacd5d..93862e6 100644
--- a/lib/filters/filter-sysfs.c
+++ b/lib/filters/filter-sysfs.c
@@ -274,8 +274,9 @@ static int _accept_p(struct dev_filter *f, struct device *dev)
 	if (!_set_lookup(ds, dev->dev)) {
 		log_debug_devs("%s: Skipping (sysfs)", dev_name(dev));
 		return 0;
-	} else
-		return 1;
+	}
+
+	return 1;
 }
 
 static void _destroy(struct dev_filter *f)
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index bf8cd02..91f8816 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -152,8 +152,8 @@ static uint64_t _get_prev_sector_circular(uint64_t region_start,
 {
 	if (region_ptr >= region_start + SECTOR_SIZE)
 		return region_ptr - SECTOR_SIZE;
-	else
-		return (region_start + region_size - SECTOR_SIZE);
+
+	return (region_start + region_size - SECTOR_SIZE);
 }
 
 /*
@@ -447,9 +447,9 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 	if (!strncmp(vgnamebuf, vgname, len = strlen(vgname)) &&
 	    (isspace(vgnamebuf[len]) || vgnamebuf[len] == '{'))
 		return rlocn;
-	else
-		log_debug_metadata("Volume group name found in metadata does "
-				   "not match expected name %s.", vgname);
+
+	log_debug_metadata("Volume group name found in metadata does "
+			   "not match expected name %s.", vgname);
 
       bad:
 	if ((info = lvmcache_info_from_pvid(dev_area->dev->pvid, dev_area->dev, 0)) &&
@@ -893,8 +893,9 @@ static struct volume_group *_vg_read_file_name(struct format_instance *fid,
 		log_error("'%s' does not contain volume group '%s'.",
 			  read_path, vgname);
 		return NULL;
-	} else
-		log_debug_metadata("Read volume group %s from %s", vg->name, read_path);
+	}
+
+	log_debug_metadata("Read volume group %s from %s", vg->name, read_path);
 
 	return vg;
 }
@@ -1634,10 +1635,10 @@ static int _text_pv_initialise(const struct format_type *fmt,
 				log_error("%s: Bootloader area would overlap "
 					  "data area.", pv_dev_name(pv));
 				return 0;
-			} else {
-				pv->ba_start = pva->ba_start ? : final_alignment;
-				pv->ba_size = pva->ba_size;
 			}
+
+			pv->ba_start = pva->ba_start ? : final_alignment;
+			pv->ba_size = pva->ba_size;
 		}
 	}
 
diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index b031833..a04d9c7 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -519,11 +519,14 @@ static int decode_lock_type(const char *response)
 {
 	if (!response)
 		return LCK_NULL;
-	else if (!strcmp(response, "EX"))
+
+	if (!strcmp(response, "EX"))
 		return LCK_EXCL;
-	else if (!strcmp(response, "CR"))
+
+	if (!strcmp(response, "CR"))
 		return LCK_READ;
-	else if (!strcmp(response, "PR"))
+
+	if (!strcmp(response, "PR"))
 		return LCK_PREAD;
 
 	return_0;
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index afc001a..2886fc4 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -187,9 +187,9 @@ int init_locking(int type, struct cmd_context *cmd, int suppress_messages)
 				  "be inaccessible.");
 		if (init_file_locking(&_locking, cmd, suppress_messages))
 			return 1;
-		else
-			log_error_suppress(suppress_messages,
-					   "File-based locking initialisation failed.");
+
+		log_error_suppress(suppress_messages,
+				   "File-based locking initialisation failed.");
 	}
 
 	if (!ignorelockingfailure())
@@ -232,7 +232,9 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname)
 		log_error("%s exists: Is the original LVM driver using "
 			  "this volume group?", path);
 		return 0;
-	} else if (errno != ENOENT && errno != ENOTDIR) {
+	}
+
+	if (errno != ENOENT && errno != ENOTDIR) {
 		log_sys_error("stat", path);
 		return 0;
 	}
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 94a674f..54e3cf6 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -1596,15 +1596,15 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 			 */
 			log_error("Global lock failed: held by other host.");
 			return 0;
-		} else {
-			/*
-			 * We don't intend to reach this.  We should check
-			 * any known/possible error specifically and print
-			 * a more helpful message.  This is for completeness.
-			 */
-			log_error("Global lock failed: error %d.", result);
-			return 0;
 		}
+
+		/*
+		 * We don't intend to reach this.  We should check
+		 * any known/possible error specifically and print
+		 * a more helpful message.  This is for completeness.
+		 */
+		log_error("Global lock failed: error %d.", result);
+		return 0;
 	}
 
  allow:
@@ -2330,15 +2330,16 @@ int lockd_init_lv(struct cmd_context *cmd, struct volume_group *vg, struct logic
 	if (!_lvmlockd_connected)
 		return 0;
 
-	if (!lp->needs_lockd_init) {
+	if (!lp->needs_lockd_init)
 		/* needs_lock_init is set for LVs that need a lockd lock. */
 		return 1;
 
-	} else if (seg_is_cache(lp) || seg_is_cache_pool(lp)) {
+	if (seg_is_cache(lp) || seg_is_cache_pool(lp)) {
 		log_error("Use lvconvert for cache with lock type %s", vg->lock_type);
 		return 0;
+	}
 
-	} else if (!seg_is_thin_volume(lp) && lp->snapshot) {
+	if (!seg_is_thin_volume(lp) && lp->snapshot) {
 		struct logical_volume *origin_lv;
 
 		/*
@@ -2363,8 +2364,9 @@ int lockd_init_lv(struct cmd_context *cmd, struct volume_group *vg, struct logic
 		}
 		lv->lock_args = NULL;
 		return 1;
+	}
 
-	} else if (seg_is_thin(lp)) {
+	if (seg_is_thin(lp)) {
 		if ((seg_is_thin_volume(lp) && !lp->create_pool) ||
 		    (!seg_is_thin_volume(lp) && lp->snapshot)) {
 			struct lv_list *lvl;
@@ -2385,8 +2387,9 @@ int lockd_init_lv(struct cmd_context *cmd, struct volume_group *vg, struct logic
 			}
 			lv->lock_args = NULL;
 			return 1;
+		}
 
-		} else if (seg_is_thin_volume(lp) && lp->create_pool) {
+		if (seg_is_thin_volume(lp) && lp->create_pool) {
 			/*
 			 * Creating a thin pool and a thin lv in it.  We could
 			 * probably make this work.
@@ -2394,21 +2397,21 @@ int lockd_init_lv(struct cmd_context *cmd, struct volume_group *vg, struct logic
 			log_error("Create thin pool and thin LV separately with lock type %s",
 				  vg->lock_type);
 			return 0;
+		}
 
-		} else if (!seg_is_thin_volume(lp) && lp->create_pool) {
+		if (!seg_is_thin_volume(lp) && lp->create_pool) {
 			/* Creating a thin pool only. */
 			/* lv_name_lock = lp->pool_name; */
 
-		} else {
-			log_error("Unknown thin options for lock init.");
-			return 0;
 		}
 
-	} else {
-		/* Creating a normal lv. */
-		/* lv_name_lock = lv_name; */
+		log_error("Unknown thin options for lock init.");
+		return 0;
 	}
 
+	/* Creating a normal lv. */
+	/* lv_name_lock = lv_name; */
+
 	/*
 	 * The LV gets its own lock, so set lock_args to non-NULL.
 	 *
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index c87bb6b..e3815c9 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -581,8 +581,8 @@ static char *_do_lv_origin_dup(struct dm_pool *mem, const struct logical_volume
 
 	if (uuid)
 		return lv_uuid_dup(mem, origin_lv);
-	else
-		return lv_name_dup(mem, origin_lv);
+
+	return lv_name_dup(mem, origin_lv);
 }
 
 char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv)
@@ -650,6 +650,7 @@ char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv)
 
 	if (!list_lv_modules(mem, lv, modules))
 		return_NULL;
+
 	return tags_format_and_copy(mem, modules);
 }
 
@@ -675,8 +676,8 @@ static char *_do_lv_mirror_log_dup(struct dm_pool *mem, const struct logical_vol
 
 	if (uuid)
 		return lv_uuid_dup(mem, mirror_log_lv);
-	else
-		return lv_name_dup(mem, mirror_log_lv);
+
+	return lv_name_dup(mem, mirror_log_lv);
 }
 
 char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv)
@@ -708,8 +709,8 @@ static char *_do_lv_pool_lv_dup(struct dm_pool *mem, const struct logical_volume
 
 	if (uuid)
 		return lv_uuid_dup(mem, pool_lv);
-	else
-		return lv_name_dup(mem, pool_lv);
+
+	return lv_name_dup(mem, pool_lv);
 }
 
 char *lv_pool_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
@@ -741,8 +742,8 @@ static char *_do_lv_data_lv_dup(struct dm_pool *mem, const struct logical_volume
 
 	if (uuid)
 		return lv_uuid_dup(mem, data_lv);
-	else
-		return lv_name_dup(mem, data_lv);
+
+	return lv_name_dup(mem, data_lv);
 }
 
 char *lv_data_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
@@ -774,8 +775,8 @@ static char *_do_lv_metadata_lv_dup(struct dm_pool *mem, const struct logical_vo
 
 	if (uuid)
 		return lv_uuid_dup(mem, metadata_lv);
-	else
-		return lv_name_dup(mem, metadata_lv);
+
+	return lv_name_dup(mem, metadata_lv);
 }
 
 char *lv_metadata_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
@@ -792,7 +793,8 @@ const char *lv_layer(const struct logical_volume *lv)
 {
 	if (lv_is_thin_pool(lv))
 		return "tpool";
-	else if (lv_is_origin(lv) || lv_is_external_origin(lv))
+
+	if (lv_is_origin(lv) || lv_is_external_origin(lv))
 		return "real";
 
 	return NULL;
@@ -841,8 +843,8 @@ static char *_do_lv_convert_lv_dup(struct dm_pool *mem, const struct logical_vol
 
 	if (uuid)
 		return lv_uuid_dup(mem, convert_lv);
-	else
-		return lv_name_dup(mem, convert_lv);
+
+	return lv_name_dup(mem, convert_lv);
 }
 
 char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
@@ -877,8 +879,8 @@ static char *_do_lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume
 
 			if (uuid)
 				return pv_uuid_dup(mem, pvseg->pv);
-			else
-				return pv_name_dup(mem, pvseg->pv);
+
+			return pv_name_dup(mem, pvseg->pv);
 		}
 	}
 
@@ -1104,12 +1106,8 @@ int lv_raid_healthy(const struct logical_volume *lv)
 	if (!lv_raid_dev_health(raid_seg->lv, &raid_health))
 		return_0;
 
-	if (lv_is_raid(lv)) {
-		if (strchr(raid_health, 'D'))
-			return 0;
-		else
-			return 1;
-	}
+	if (lv_is_raid(lv))
+		return (strchr(raid_health, 'D')) ? 0 : 1;
 
 	/* Find out which sub-LV this is. */
 	for (s = 0; s < raid_seg->area_count; s++)
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 0b90705..5c2e722 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -990,7 +990,8 @@ static uint32_t _raid_data_copies(struct lv_segment *seg)
 	 */
 	if (seg_is_raid10(seg))
 		return 2;
-	else if (seg_is_raid1(seg))
+
+	if (seg_is_raid1(seg))
 		return seg->area_count;
 
 	return seg->segtype->parity_devs + 1;
@@ -1531,11 +1532,11 @@ int historical_glv_remove(struct generic_logical_volume *glv)
 			log_error(INTERNAL_ERROR "historical_glv_remove: historical LV %s/-%s not found ",
 				  hlv->vg->name, hlv->name);
 			return 0;
-		} else {
-			log_verbose("Historical LV %s/-%s already on removed list ",
-				    hlv->vg->name, hlv->name);
-			return 1;
 		}
+
+		log_verbose("Historical LV %s/-%s already on removed list ",
+			    hlv->vg->name, hlv->name);
+		return 1;
 	}
 
 	if ((origin_glv = hlv->indirect_origin) &&
@@ -2057,7 +2058,7 @@ static int _comp_area(const void *l, const void *r)
 	if (lhs->used < rhs->used)
 		return 1;
 
-	else if (lhs->used > rhs->used)
+	if (lhs->used > rhs->used)
 		return -1;
 
 	return 0;
@@ -5773,7 +5774,9 @@ struct logical_volume *lv_create_empty(const char *name,
 		log_error("Failed to generate unique name for the new "
 			  "logical volume");
 		return NULL;
-	} else if (lv_name_is_used_in_vg(vg, name, &historical)) {
+	}
+
+	if (lv_name_is_used_in_vg(vg, name, &historical)) {
 		log_error("Unable to create LV %s in Volume Group %s: "
 			  "name already in use%s.", name, vg->name,
 			  historical ? " by historical LV" : "");
@@ -6000,7 +6003,9 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		log_error("Can't remove logical volume %s used by a pool.",
 			  display_lvname(lv));
 		return 0;
-	} else if (lv_is_thin_volume(lv)) {
+	}
+
+	if (lv_is_thin_volume(lv)) {
 		if (!(pool_lv = first_seg(lv)->pool_lv)) {
 			log_error(INTERNAL_ERROR "Thin LV %s without pool.",
 				  display_lvname(lv));
@@ -6036,9 +6041,9 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 					  display_lvname(lv)) == 'n') {
 				log_error("Logical volume %s not removed.", display_lvname(lv));
 				return 0;
-			} else {
-				ask_discard = 0;
 			}
+
+			ask_discard = 0;
 		}
 	}
 
@@ -6269,18 +6274,21 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 						  display_lvname(lv));
 					return 0;
 				}
+
 				if ((snap_percent != DM_PERCENT_INVALID) &&
 				     (snap_percent != LVM_PERCENT_MERGE_FAILED)) {
 					log_error("Can't remove merging snapshot logical volume %s.",
 						  display_lvname(lv));
 					return 0;
-				} else if ((snap_percent == LVM_PERCENT_MERGE_FAILED) &&
-					   (force == PROMPT) &&
-					   yes_no_prompt("Removing snapshot %s that failed to merge "
-							 "may leave origin %s inconsistent. Proceed? [y/n]: ",
-							 display_lvname(lv),
-							 display_lvname(origin_from_cow(lv))) == 'n')
-                                        goto no_remove;
+				}
+
+				if ((snap_percent == LVM_PERCENT_MERGE_FAILED) &&
+				    (force == PROMPT) &&
+				    yes_no_prompt("Removing snapshot %s that failed to merge "
+						  "may leave origin %s inconsistent. Proceed? [y/n]: ",
+						  display_lvname(lv),
+						  display_lvname(origin_from_cow(lv))) == 'n')
+					goto no_remove;
 			}
 		} else if (!level && lv_is_virtual_origin(origin = origin_from_cow(lv)))
 			/* If this is a sparse device, remove its origin too. */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 45495dc..d8f993c 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -198,7 +198,9 @@ static int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 		log_error("Physical volume '%s' is already in volume group "
 			  "'%s'", pv_name, pv->vg_name);
 		return 0;
-	} else if (!new_pv) {
+	}
+
+	if (!new_pv) {
 		if ((used = is_used_pv(pv)) < 0)
 			return_0;
 
@@ -730,7 +732,9 @@ static int vg_extend_single_pv(struct volume_group *vg, char *pv_name,
 		log_error("%s not identified as an existing "
 			  "physical volume", pv_name);
 		return 0;
-	} else if (!pv && pp) {
+	}
+
+	if (!pv && pp) {
 		if (!(pv = pvcreate_vol(vg->cmd, pv_name, pp, 0)))
 			return_0;
 		new_pv = 1;
@@ -5725,10 +5729,10 @@ static int _access_vg_lock_type(struct cmd_context *cmd, struct volume_group *vg
 			log_error("Cannot access VG %s due to failed lock.", vg->name);
 			*failure |= FAILED_LOCK_MODE;
 			return 0;
-		} else {
-			log_warn("Reading VG %s without a lock.", vg->name);
-			return 1;
 		}
+
+		log_warn("Reading VG %s without a lock.", vg->name);
+		return 1;
 	}
 
 	if (test_mode()) {
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 52e1488..7496ddc 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1532,8 +1532,8 @@ const char *get_pvmove_pvname_from_lv(const struct logical_volume *lv)
 
 	if (pvmove_lv)
 		return get_pvmove_pvname_from_lv_mirr(pvmove_lv);
-	else
-		return NULL;
+
+	return NULL;
 }
 
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
@@ -2170,7 +2170,9 @@ int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		return _add_mirrors_that_preserve_segments(lv, MIRROR_BY_SEG,
 							   mirrors, region_size,
 							   pvs, alloc);
-	} else if (flags & MIRROR_BY_SEGMENTED_LV) {
+	}
+
+	if (flags & MIRROR_BY_SEGMENTED_LV) {
 		if (stripes > 1) {
 			log_error("Striped-mirroring is not supported on "
 				  "segment-by-segment mirroring.");
@@ -2180,7 +2182,9 @@ int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		return _add_mirrors_that_preserve_segments(lv, MIRROR_BY_SEGMENTED_LV,
 							   mirrors, region_size,
 							   pvs, alloc);
-	} else if (flags & MIRROR_BY_LV) {
+	}
+
+	if (flags & MIRROR_BY_LV) {
 		if (!mirrors)
 			return add_mirror_log(cmd, lv, log_count,
 					      region_size, pvs, alloc);
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index a8cd763..de6644e 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -358,10 +358,11 @@ static uint32_t _overlap_pe(const struct pv_segment *pvseg,
 
 	start = max(pvseg->pe, per->start);
 	end = min(pvseg->pe + pvseg->len, per->start + per->count);
+
 	if (end < start)
 		return 0;
-	else
-		return end - start;
+
+	return end - start;
 }
 
 /*
@@ -608,8 +609,8 @@ static int pv_resize(struct physical_volume *pv,
 
 		if (new_pe_count > old_pe_count)
 			return _extend_pv(pv, vg, old_pe_count, new_pe_count);
-		else
-			return _reduce_pv(pv, vg, old_pe_count, new_pe_count);
+
+		return _reduce_pv(pv, vg, old_pe_count, new_pe_count);
 	}
 
 	return 1;
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 84c14ba..d96eceb 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1251,10 +1251,13 @@ uint32_t lv_raid_data_copies(const struct segment_type *segtype, uint32_t area_c
 	if (segtype_is_any_raid10(segtype))
 		/* FIXME: change for variable number of data copies */
 		return 2;
-	else if (segtype_is_mirrored(segtype))
+
+	if (segtype_is_mirrored(segtype))
 		return area_count;
-	else if (segtype_is_striped_raid(segtype))
+
+	if (segtype_is_striped_raid(segtype))
 		return segtype->parity_devs + 1;
+
 	return 1;
 }
 
@@ -4807,8 +4810,8 @@ static int _raid0_meta_change_wrapper(struct logical_volume *lv,
 
 	if (alloc_metadata_devs)
 		return _raid0_add_or_remove_metadata_lvs(lv, 1, allocate_pvs, NULL);
-	else
-		return _raid0_add_or_remove_metadata_lvs(lv, 1, allocate_pvs, &removal_lvs);
+
+	return _raid0_add_or_remove_metadata_lvs(lv, 1, allocate_pvs, &removal_lvs);
 }
 
 static int _raid0_to_striped_wrapper(struct logical_volume *lv,
@@ -6040,8 +6043,9 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 			log_error("Convert %s LV %s to 2 images first.",
 				 lvseg_name(seg_from), display_lvname(seg_from->lv));
 			return 0;
+		}
 
-		} else if (segtype_is_striped(*segtype) ||
+		if (segtype_is_striped(*segtype) ||
 			   segtype_is_any_raid0(*segtype) ||
 			   segtype_is_raid10(*segtype))
 			seg_flag = SEG_RAID5_N;
@@ -6056,8 +6060,9 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 			log_error("Convert %s LV %s to 2 stripes first (i.e. --stripes 1).",
 				  lvseg_name(seg_from), display_lvname(seg_from->lv));
 			return 0;
+		}
 
-		} else if (seg_is_raid4(seg_from) &&
+		if (seg_is_raid4(seg_from) &&
 			   segtype_is_any_raid5(*segtype) &&
 			   !segtype_is_raid5_n(*segtype))
 			seg_flag = SEG_RAID5_N;
@@ -6081,8 +6086,9 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 				log_error("Convert %s LV %s to minimum 4 stripes first (i.e. --stripes 3).",
 					  lvseg_name(seg_from), display_lvname(seg_from->lv));
 				return 0;
+			}
 
-			} else if (seg_is_raid4(seg_from) && !segtype_is_raid6_n_6(*segtype))
+			if (seg_is_raid4(seg_from) && !segtype_is_raid6_n_6(*segtype))
 				seg_flag = SEG_RAID6_N_6;
 			else
 				seg_flag = _raid_seg_flag_5_to_6(seg_from);
@@ -6118,12 +6124,12 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 			log_error("Convert %s LV %s to raid4/raid5 first.",
 				  lvseg_name(seg_from), display_lvname(seg_from->lv));
 			return 0;
+		}
 
-		} else if (seg_from->area_count != 2) {
+		if (seg_from->area_count != 2) {
 			log_error("Convert %s LV %s to 2 stripes first (i.e. --stripes 1).",
 				 lvseg_name(seg_from), display_lvname(seg_from->lv));
 			return 0;
-
 		}
 
 	/* raid10 -> ... */
@@ -6352,7 +6358,9 @@ int lv_raid_convert(struct logical_volume *lv,
 		log_error("%s must be active to perform this operation.",
 			  display_lvname(lv));
 		return 0;
-	} else if (vg_is_clustered(lv->vg) &&
+	}
+
+	if (vg_is_clustered(lv->vg) &&
 		   !lv_is_active_exclusive_locally(lv_lock_holder(lv))) {
 		/* In clustered VGs, the LV must be active on this node exclusively. */
 		log_error("%s must be active exclusive locally to "
@@ -6710,17 +6718,23 @@ static int _lv_raid_rebuild_or_replace(struct logical_volume *lv,
 		log_print_unless_silent("%s does not contain devices specified to %s.",
 					display_lvname(lv), action_str);
 		return 1;
-	} else if (match_count == raid_seg->area_count) {
+	}
+
+	if (match_count == raid_seg->area_count) {
 		log_error("Unable to %s all PVs from %s at once.",
 			  action_str, display_lvname(lv));
 		return 0;
-	} else if (raid_seg->segtype->parity_devs &&
-		   (match_count > raid_seg->segtype->parity_devs)) {
+	}
+
+	if (raid_seg->segtype->parity_devs &&
+	    (match_count > raid_seg->segtype->parity_devs)) {
 		log_error("Unable to %s more than %u PVs from (%s) %s.",
 			  action_str, raid_seg->segtype->parity_devs,
 			  lvseg_name(raid_seg), display_lvname(lv));
 		return 0;
-	} else if (seg_is_raid10(raid_seg)) {
+	}
+
+	if (seg_is_raid10(raid_seg)) {
 		uint32_t i, rebuilds_per_group = 0;
 		/* FIXME: We only support 2-way mirrors (i.e. 2 data copies) in RAID10 currently */
 		uint32_t copies = 2;
@@ -7039,8 +7053,10 @@ static int _partial_raid_lv_is_redundant(const struct logical_volume *lv)
 		log_verbose("All components of raid LV %s have failed.",
 			    display_lvname(lv));
 		return 0;	/* Insufficient redundancy to activate */
-	} else if (raid_seg->segtype->parity_devs &&
-		   (failed_components > raid_seg->segtype->parity_devs)) {
+	}
+
+	if (raid_seg->segtype->parity_devs &&
+	    (failed_components > raid_seg->segtype->parity_devs)) {
 		log_verbose("More than %u components from %s %s have failed.",
 			    raid_seg->segtype->parity_devs,
 			    lvseg_name(raid_seg),
diff --git a/lib/replicator/replicator.c b/lib/replicator/replicator.c
index aaf2296..8f43f8b 100644
--- a/lib/replicator/replicator.c
+++ b/lib/replicator/replicator.c
@@ -627,7 +627,9 @@ static int _replicator_dev_add_target_line(struct dev_manager *dm,
 		if (!(rdev_dlid = build_dm_uuid(mem, seg->lv->rdevice->lv, NULL)))
 			return_0;
 		return dm_tree_node_add_target_area(node, NULL, rdev_dlid, 0);
-	} else if (seg->lv->rdevice->rsite->site_index) {
+	}
+
+	if (seg->lv->rdevice->rsite->site_index) {
 		log_error("Active site with site_index != 0 (%s, %d)",
 			  seg->lv->rdevice->rsite->name,
 			  seg->lv->rdevice->rsite->site_index);
diff --git a/lib/report/report.c b/lib/report/report.c
index 71fe35a..89110f0 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -732,7 +732,9 @@ static int _check_time_items(struct time_info *info)
 			if (label_date) {
 				log_error("Ambiguous date specification found at \"%s\".", ti->s);
 				return 0;
-			} else if (_is_time_label_date(ti->prop->id))
+			}
+
+			if (_is_time_label_date(ti->prop->id))
 				label_date = 1;
 		}
 
@@ -749,7 +751,9 @@ static int _check_time_items(struct time_info *info)
 			if (label_time) {
 				log_error("Ambiguous time specification found at \"%s\".", ti->s);
 				return 0;
-			} else if (_is_time_label_time(ti->prop->id))
+			}
+
+			if (_is_time_label_time(ti->prop->id))
 				label_time = 1;
 		}
 	}
@@ -1251,9 +1255,9 @@ static int _binary_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 	if (cmd->report_binary_values_as_numeric)
 		/* "0"/"1" */
 		return _field_set_value(field, bin_value ? _str_one : _str_zero, bin_value ? &_one64 : &_zero64);
-	else
-		/* blank/"word" */
-		return _field_set_value(field, bin_value ? word : "", bin_value ? &_one64 : &_zero64);
+
+	/* blank/"word" */
+	return _field_set_value(field, bin_value ? word : "", bin_value ? &_one64 : &_zero64);
 }
 
 static int _binary_undef_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -1263,8 +1267,8 @@ static int _binary_undef_disp(struct dm_report *rh, struct dm_pool *mem __attrib
 
 	if (cmd->report_binary_values_as_numeric)
 		return _field_set_value(field, GET_FIRST_RESERVED_NAME(num_undef_64), &GET_TYPE_RESERVED_VALUE(num_undef_64));
-	else
-		return _field_set_value(field, _str_unknown, &GET_TYPE_RESERVED_VALUE(num_undef_64));
+
+	return _field_set_value(field, _str_unknown, &GET_TYPE_RESERVED_VALUE(num_undef_64));
 }
 
 static int _string_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -1772,8 +1776,8 @@ static int _do_loglv_disp(struct dm_report *rh, struct dm_pool *mem,
 
 	if (uuid)
 		return _uuid_disp(rh, mem, field, &mirror_log_lv->lvid.id[1], private);
-	else
-		return _lvname_disp(rh, mem, field, mirror_log_lv, private);
+
+	return _lvname_disp(rh, mem, field, mirror_log_lv, private);
 }
 
 static int _loglv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -1829,8 +1833,8 @@ static int _do_datalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute
 
 	if (uuid)
 		return _uuid_disp(rh, mem, field, &data_lv->lvid.id[1], private);
-	else
-		return _lvname_disp(rh, mem, field, data_lv, private);
+
+	return _lvname_disp(rh, mem, field, data_lv, private);
 }
 
 static int _datalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -1860,8 +1864,8 @@ static int _do_metadatalv_disp(struct dm_report *rh, struct dm_pool *mem __attri
 
 	if (uuid)
 		return _uuid_disp(rh, mem, field, &metadata_lv->lvid.id[1], private);
-	else
-		return _lvname_disp(rh, mem, field, metadata_lv, private);
+
+	return _lvname_disp(rh, mem, field, metadata_lv, private);
 }
 
 static int _metadatalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -1891,8 +1895,8 @@ static int _do_poollv_disp(struct dm_report *rh, struct dm_pool *mem,
 
 	if (uuid)
 		return _uuid_disp(rh, mem, field, &pool_lv->lvid.id[1], private);
-	else
-		return _lvname_disp(rh, mem, field, pool_lv, private);
+
+	return _lvname_disp(rh, mem, field, pool_lv, private);
 }
 
 static int _poollv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -1948,8 +1952,8 @@ static int _do_origin_disp(struct dm_report *rh, struct dm_pool *mem,
 
 	if (uuid)
 		return _uuid_disp(rh, mem, field, &origin_lv->lvid.id[1], private);
-	else
-		return _lvname_disp(rh, mem, field, origin_lv, private);
+
+	return _lvname_disp(rh, mem, field, origin_lv, private);
 }
 
 static int _origin_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -2241,8 +2245,8 @@ static int _do_convertlv_disp(struct dm_report *rh, struct dm_pool *mem,
 
 	if (uuid)
 		return _uuid_disp(rh, mem, field, &convert_lv->lvid.id[1], private);
-	else
-		return _lvname_disp(rh, mem, field, convert_lv, private);
+
+	return _lvname_disp(rh, mem, field, convert_lv, private);
 }
 
 static int _convertlv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -2361,9 +2365,9 @@ static int _lvwhenfull_disp(struct dm_report *rh, struct dm_pool *mem,
 		if (lv->status & LV_ERROR_WHEN_FULL)
 			return _field_set_value(field, GET_FIRST_RESERVED_NAME(lv_when_full_error),
 						GET_FIELD_RESERVED_VALUE(lv_when_full_error));
-		else
-			return _field_set_value(field, GET_FIRST_RESERVED_NAME(lv_when_full_queue),
-						GET_FIELD_RESERVED_VALUE(lv_when_full_queue));
+
+		return _field_set_value(field, GET_FIRST_RESERVED_NAME(lv_when_full_queue),
+					GET_FIELD_RESERVED_VALUE(lv_when_full_queue));
 	}
 
 	return _field_set_value(field, GET_FIRST_RESERVED_NAME(lv_when_full_undef),
@@ -3584,8 +3588,8 @@ static int _lvactiveremotely_disp(struct dm_report *rh, struct dm_pool *mem,
 		 */
 		if (lv_is_active_locally(lv))
 			return _binary_undef_disp(rh, mem, field, private);
-		else
-			active_remotely = lv_is_active_but_not_locally(lv);
+
+		active_remotely = lv_is_active_but_not_locally(lv);
 	} else
 		active_remotely = 0;
 
@@ -3725,7 +3729,7 @@ static int _lvhealthstatus_disp(struct dm_report *rh, struct dm_pool *mem,
 		if (lvdm->seg_status.type != SEG_STATUS_CACHE)
 			return _field_set_value(field, GET_FIRST_RESERVED_NAME(health_undef),
 						GET_FIELD_RESERVED_VALUE(health_undef));
-		else if (lvdm->seg_status.cache->fail)
+		if (lvdm->seg_status.cache->fail)
 			health = "failed";
 		else if (lvdm->seg_status.cache->read_only)
 			health = "metadata_read_only";
@@ -3733,7 +3737,7 @@ static int _lvhealthstatus_disp(struct dm_report *rh, struct dm_pool *mem,
 		if (lvdm->seg_status.type != SEG_STATUS_THIN_POOL)
 			return _field_set_value(field, GET_FIRST_RESERVED_NAME(health_undef),
 						GET_FIELD_RESERVED_VALUE(health_undef));
-		else if (lvdm->seg_status.thin_pool->fail)
+		if (lvdm->seg_status.thin_pool->fail)
 			health = "failed";
 		else if (lvdm->seg_status.thin_pool->out_of_data_space)
 			health = "out_of_data";
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 65e75f6..c47e084 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -208,8 +208,9 @@ static int _get_proc_number(const char *file, const char *name,
 		if (require_module_loaded) {
 			log_error("%s: No entry for %s found", file, name);
 			return 0;
-		} else
-			return 2;
+		}
+
+		return 2;
 	}
 
 	return 1;
@@ -368,11 +369,11 @@ int dm_is_dm_major(uint32_t major)
 			return 0;
 		return dm_bit(_dm_bitset, major) ? 1 : 0;
 	}
-	else {
-		if (!_dm_device_major)
-			return 0;
-		return (major == _dm_device_major) ? 1 : 0;
-	}
+
+	if (!_dm_device_major)
+		return 0;
+
+	return (major == _dm_device_major) ? 1 : 0;
 }
 
 static void _close_control_fd(void)
@@ -1704,7 +1705,9 @@ static int _do_dm_ioctl_unmangle_string(char *str, const char *str_name,
 		log_debug_activation("_do_dm_ioctl_unmangle_string: failed to "
 				     "unmangle %s \"%s\"", str_name, str);
 		return 0;
-	} else if (r)
+	}
+
+	if (r)
 		memcpy(str, buf, strlen(buf) + 1);
 
 	return 1;
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index d8cf946..e983b03 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1137,13 +1137,12 @@ static int _rename_dev_node(const char *old_name, const char *new_name,
 				 errno == ENOENT)
 				/* assume udev already deleted this */
 				return 1;
-			else {
-				log_warn("The node %s should have been renamed to %s "
-					 "by udev but old node is still present. "
-					 "Falling back to direct old node removal.",
-					 oldpath, newpath);
-				return _rm_dev_node(old_name, 0);
-			}
+
+			log_warn("The node %s should have been renamed to %s "
+				 "by udev but old node is still present. "
+				 "Falling back to direct old node removal.",
+				 oldpath, newpath);
+			return _rm_dev_node(old_name, 0);
 		}
 
 		if (unlink(newpath) < 0) {
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index a5100d4..d2371db 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1013,16 +1013,18 @@ static int _field_match(struct dm_report *rh, const char *field, size_t flen,
 			rh->report_types |= implicit ? _implicit_report_fields[f].type
 						     : rh->fields[f].type;
 			return 1;
-		} else
-			return _add_field(rh, f, implicit, 0) ? 1 : 0;
+		}
+
+		return _add_field(rh, f, implicit, 0) ? 1 : 0;
 	}
 
 	if ((type = _all_match(rh, field, flen))) {
 		if (report_type_only) {
 			rh->report_types |= type;
 			return 1;
-		} else
-			return  _add_all_fields(rh, type);
+		}
+
+		return  _add_all_fields(rh, type);
 	}
 
 	return 0;
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index cbaae22..803ae56 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4538,10 +4538,11 @@ static int _ls(CMD_ARGS)
 	if ((_switches[TARGET_ARG] && _target) ||
 	    (_switches[EXEC_ARG] && _command_to_exec))
 		return _status(cmd, NULL, argc, argv, NULL, 0);
-	else if ((_switches[TREE_ARG]))
+
+	if ((_switches[TREE_ARG]))
 		return _display_tree(cmd, NULL, 0, NULL, NULL, 0);
-	else
-		return _process_all(cmd, NULL, argc, argv, 0, _display_name);
+
+	return _process_all(cmd, NULL, argc, argv, 0, _display_name);
 }
 
 static int _mangle(CMD_ARGS)
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index cfdf5de..d90e675 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -341,9 +341,9 @@ static int _lvconvert_poll_by_id(struct cmd_context *cmd, struct poll_operation_
 				(MERGING | (is_merging_origin_thin ? THIN_VOLUME : SNAPSHOT)),
 				is_merging_origin_thin ? &_lvconvert_thin_merge_fns : &_lvconvert_merge_fns,
 				"Merged", id);
-	else
-		return poll_daemon(cmd, background, CONVERTING,
-				&_lvconvert_mirror_fns, "Converted", id);
+
+	return poll_daemon(cmd, background, CONVERTING,
+			   &_lvconvert_mirror_fns, "Converted", id);
 }
 
 int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv,
@@ -1313,7 +1313,9 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 			log_error("Linear LV %s cannot be converted to %s.",
 				  display_lvname(lv), lp->type_str);
 			return 0;
-		} else if (!strcmp(lp->type_str, SEG_TYPE_NAME_RAID1)) {
+		}
+
+		if (!strcmp(lp->type_str, SEG_TYPE_NAME_RAID1)) {
 			log_error("Raid conversions of LV %s require -m/--mirrors.",
 				  display_lvname(lv));
 			return 0;
@@ -3398,10 +3400,11 @@ static int _lvconvert_repair_pvs_or_thinpool_single(struct cmd_context *cmd, str
 {
 	if (lv_is_thin_pool(lv))
 		return _lvconvert_repair_thinpool(cmd, lv, handle);
-	else if (lv_is_raid(lv) || lv_is_mirror(lv))
+
+	if (lv_is_raid(lv) || lv_is_mirror(lv))
 		return _lvconvert_repair_pvs(cmd, lv, handle);
-	else
-		return_ECMD_FAILED;
+
+	return_ECMD_FAILED;
 }
 
 /*
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index f464896..d2199f5 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -628,7 +628,9 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 		log_error("Only up to %u stripes in %s supported currently.",
 			  max_images / lp->mirrors, lp->segtype->name);
 		return 0;
-	} else if (seg_is_mirrored(lp)) {
+	}
+
+	if (seg_is_mirrored(lp)) {
 		if (lp->mirrors > max_images) {
 			log_error("Only up to %u mirrors in %s supported currently.",
 				  max_images, lp->segtype->name);
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 33fe947..a4df22e 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -559,17 +559,18 @@ static int _lvmpoll_daemon(struct cmd_context *cmd, struct poll_operation_id *id
 		}
 
 		return r ? ECMD_PROCESSED : ECMD_FAILED;
-	} else {
-		/* process all in-flight operations */
-		if (!(handle = init_processing_handle(cmd, NULL))) {
-			log_error("Failed to initialize processing handle.");
-			return ECMD_FAILED;
-		} else {
-			_lvmpolld_poll_for_all_vgs(cmd, parms, handle);
-			destroy_processing_handle(cmd, handle);
-			return ECMD_PROCESSED;
-		}
 	}
+
+	/* process all in-flight operations */
+	if (!(handle = init_processing_handle(cmd, NULL))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	_lvmpolld_poll_for_all_vgs(cmd, parms, handle);
+	destroy_processing_handle(cmd, handle);
+
+	return ECMD_PROCESSED;
 }
 #else
 #	define _lvmpoll_daemon(cmd, id, parms) (ECMD_FAILED)
@@ -592,7 +593,8 @@ static int _poll_daemon(struct cmd_context *cmd, struct poll_operation_id *id,
 		daemon_mode = become_daemon(cmd, 0);
 		if (daemon_mode == 0)
 			return ECMD_PROCESSED;	    /* Parent */
-		else if (daemon_mode == 1)
+
+		if (daemon_mode == 1)
 			parms->progress_display = 0; /* Child */
 		/* FIXME Use wait_event (i.e. interval = 0) and */
 		/*       fork one daemon per copy? */
@@ -680,9 +682,8 @@ int poll_daemon(struct cmd_context *cmd, unsigned background,
 
 	if (lvmpolld_use())
 		return _lvmpoll_daemon(cmd, id, &parms);
-	else {
-		/* classical polling allows only PMVOVE or 0 values */
-		parms.lv_type &= PVMOVE;
-		return _poll_daemon(cmd, id, &parms);
-	}
+
+	/* classical polling allows only PMVOVE or 0 values */
+	parms.lv_type &= PVMOVE;
+	return _poll_daemon(cmd, id, &parms);
 }
diff --git a/tools/toollib.c b/tools/toollib.c
index 9e89ed7..5e3fedd 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -938,9 +938,9 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 			if (clustery) {
 				log_error("The --clustered option requires clvmd (locking_type=3).");
 				return 0;
-			} else {
-				lock_type = "none";
 			}
+
+			lock_type = "none";
 		}
 
 	} else if (arg_is_set(cmd, shared_ARG)) {
@@ -4676,11 +4676,11 @@ int pvcreate_params_from_args(struct cmd_context *cmd, struct pvcreate_params *p
 		log_error("labelsector must be less than %lu.",
 			  LABEL_SCAN_SECTORS);
 		return 0;
-	} else {
-		pp->pva.label_sector = arg_int64_value(cmd, labelsector_ARG,
-						  DEFAULT_LABELSECTOR);
 	}
 
+	pp->pva.label_sector = arg_int64_value(cmd, labelsector_ARG,
+					       DEFAULT_LABELSECTOR);
+
 	if (!(cmd->fmt->features & FMT_MDAS) &&
 	    (arg_is_set(cmd, pvmetadatacopies_ARG) ||
 	     arg_is_set(cmd, metadatasize_ARG)   ||
@@ -5084,7 +5084,9 @@ static int _pvcreate_check_single(struct cmd_context *cmd,
 			log_error("Can't get device size of %s.", pv_dev_name(pv));
 			dm_list_move(&pp->arg_fail, &pd->list);
 			return 1;
-		} else if (new_size != size)
+		}
+
+		if (new_size != size)
 			need_size_prompt = 1;
 	}
 
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index 7fc64b0..f4b0b6f 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -60,13 +60,16 @@ int vgdisplay(struct cmd_context *cmd, int argc, char **argv)
 			return EINVALID_CMD_LINE;
 		}
 		return vgs(cmd, argc, argv);
-	} else if (arg_is_set(cmd, aligned_ARG) ||
-		   arg_is_set(cmd, binary_ARG) ||
-		   arg_is_set(cmd, noheadings_ARG) ||
-		   arg_is_set(cmd, options_ARG) ||
-		   arg_is_set(cmd, separator_ARG) ||
-		   arg_is_set(cmd, sort_ARG) || arg_is_set(cmd, unbuffered_ARG)) {
-		log_error("Incompatible options selected");
+	}
+
+	if (arg_is_set(cmd, aligned_ARG) ||
+	    arg_is_set(cmd, binary_ARG) ||
+	    arg_is_set(cmd, noheadings_ARG) ||
+	    arg_is_set(cmd, options_ARG) ||
+	    arg_is_set(cmd, separator_ARG) ||
+	    arg_is_set(cmd, sort_ARG) ||
+	    arg_is_set(cmd, unbuffered_ARG)) {
+		log_error("Incompatible options selected.");
 		return EINVALID_CMD_LINE;
 	}
 


