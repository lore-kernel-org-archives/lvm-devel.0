From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 16 Dec 2009 19:22:14 -0000
Subject: LVM2 lib/activate/dev_manager.c lib/cache/lvmc ...
Message-ID: <20091216192214.22164.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-12-16 19:22:13

Modified files:
	lib/activate   : dev_manager.c 
	lib/cache      : lvmcache.c 
	lib/format_text: export.c text_label.c 
	lib/locking    : locking.c 
	lib/log        : log.c log.h 
	lib/metadata   : metadata.c 
	lib/mm         : memlock.c 
	lib/striped    : striped.c 
	tools          : lvm.c lvmcmdline.c 

Log message:
	#define an INTERNAL_ERROR macro and use it throughout LVM.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.166&r2=1.167
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_label.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.h.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.302&r2=1.303
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/striped/striped.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm.c.diff?cvsroot=lvm2&r1=1.110&r2=1.111
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.108&r2=1.109

--- LVM2/lib/activate/dev_manager.c	2009/12/03 10:01:30	1.166
+++ LVM2/lib/activate/dev_manager.c	2009/12/16 19:22:11	1.167
@@ -852,7 +852,7 @@
 			dm_tree_node_add_target_area(node, NULL, dlid,
 							extent_size * seg_le(seg, s));
 		} else {
-			log_error("Internal error: Unassigned area found in LV %s.",
+			log_error(INTERNAL_ERROR "Unassigned area found in LV %s.",
 				  seg->lv->name);
 			return 0;
 		}
@@ -911,7 +911,7 @@
 	uint64_t extent_size = seg->lv->vg->extent_size;
 
 	if (!seg->segtype->ops->add_target_line) {
-		log_error("_emit_target: Internal error: Can't handle "
+		log_error(INTERNAL_ERROR "_emit_target cannot handle "
 			  "segment type %s", seg->segtype->name);
 		return 0;
 	}
--- LVM2/lib/cache/lvmcache.c	2009/11/24 16:11:37	1.73
+++ LVM2/lib/cache/lvmcache.c	2009/12/16 19:22:12	1.74
@@ -227,7 +227,7 @@
 		vgname2 = dm_hash_get_key(_lock_hash, n);
 
 		if (!_vgname_order_correct(vgname2, vgname)) {
-			log_errno(EDEADLK, "Internal error: VG lock %s must "
+			log_errno(EDEADLK, INTERNAL_ERROR "VG lock %s must "
 				  "be requested before %s, not after.",
 				  vgname, vgname2);
 			return_0;
@@ -245,7 +245,7 @@
 	}
 
 	if (dm_hash_lookup(_lock_hash, vgname))
-		log_error("Internal error: Nested locking attempted on VG %s.",
+		log_error(INTERNAL_ERROR "Nested locking attempted on VG %s.",
 			  vgname);
 
 	if (!dm_hash_insert(_lock_hash, vgname, (void *) 1))
@@ -268,7 +268,7 @@
 void lvmcache_unlock_vgname(const char *vgname)
 {
 	if (!dm_hash_lookup(_lock_hash, vgname))
-		log_error("Internal error: Attempt to unlock unlocked VG %s.",
+		log_error(INTERNAL_ERROR "Attempt to unlock unlocked VG %s.",
 			  vgname);
 
 	_update_cache_lock_state(vgname, 0);
@@ -1102,7 +1102,7 @@
 				  uint32_t vgstatus, const char *creation_host)
 {
 	if (!vgname && !info->vginfo) {
-		log_error("Internal error: NULL vgname handed to cache");
+		log_error(INTERNAL_ERROR "NULL vgname handed to cache");
 		/* FIXME Remove this */
 		vgname = info->fmt->orphan_vg_name;
 		vgid = vgname;
@@ -1296,7 +1296,7 @@
 	if (!strcmp(vgname, VG_GLOBAL))
 		_vg_global_lock_held = 1;
 	else
-		log_error("Internal error: Volume Group %s was not unlocked",
+		log_error(INTERNAL_ERROR "Volume Group %s was not unlocked",
 			  dm_hash_get_key(_lock_hash, n));
 }
 
@@ -1333,7 +1333,7 @@
 	}
 
 	if (!dm_list_empty(&_vginfos))
-		log_error("Internal error: _vginfos list should be empty");
+		log_error(INTERNAL_ERROR "_vginfos list should be empty");
 	dm_list_init(&_vginfos);
 
 	if (retain_orphans)
--- LVM2/lib/format_text/export.c	2009/11/24 22:55:56	1.72
+++ LVM2/lib/format_text/export.c	2009/12/16 19:22:12	1.73
@@ -99,7 +99,7 @@
 static void _dec_indent(struct formatter *f)
 {
 	if (!f->indent--) {
-		log_error("Internal error tracking indentation");
+		log_error(INTERNAL_ERROR "problem tracking indentation");
 		f->indent = 0;
 	}
 }
--- LVM2/lib/format_text/text_label.c	2009/11/24 22:55:56	1.26
+++ LVM2/lib/format_text/text_label.c	2009/12/16 19:22:12	1.27
@@ -137,7 +137,7 @@
 		  mda2 ? "s)" : "");
 
 	if (da1 < 0) {
-		log_error("Internal error: %s label header currently requires "
+		log_error(INTERNAL_ERROR "%s label header currently requires "
 			  "a data area.", dev_name(info->dev));
 		return 0;
 	}
--- LVM2/lib/locking/locking.c	2009/12/11 13:16:38	1.68
+++ LVM2/lib/locking/locking.c	2009/12/16 19:22:12	1.69
@@ -349,12 +349,12 @@
 	assert(resource);
 
 	if (!*resource) {
-		log_error("Internal error: Use of P_orphans is deprecated.");
+		log_error(INTERNAL_ERROR "Use of P_orphans is deprecated.");
 		return 0;
 	}
 
 	if (*resource == '#' && (flags & LCK_CACHE)) {
-		log_error("Internal error: P_%s referenced", resource);
+		log_error(INTERNAL_ERROR "P_%s referenced", resource);
 		return 0;
 	}
 
@@ -394,7 +394,7 @@
 
 
 	if (flags == LCK_NONE) {
-		log_debug("Internal error: %s: LCK_NONE lock requested", vol);
+		log_debug(INTERNAL_ERROR "%s: LCK_NONE lock requested", vol);
 		return 1;
 	}
 
--- LVM2/lib/log/log.c	2009/12/01 13:54:27	1.54
+++ LVM2/lib/log/log.c	2009/12/16 19:22:12	1.55
@@ -184,8 +184,8 @@
 	level &= ~_LOG_STDERR;
 
 	if (_abort_on_internal_errors &&
-	    !strncmp(format, "Internal error:",
-		     strlen("Internal error:")))
+	    !strncmp(format, INTERNAL_ERROR,
+		     strlen(INTERNAL_ERROR)))
 		internal_error = 1;
 
 	if (_log_suppress == 2)
--- LVM2/lib/log/log.h	2009/07/16 13:13:33	1.46
+++ LVM2/lib/log/log.h	2009/12/16 19:22:12	1.47
@@ -53,6 +53,7 @@
 #define _LOG_WARN 4
 #define _LOG_ERR 3
 #define _LOG_FATAL 2
+#define INTERNAL_ERROR "Internal error: "
 
 #define log_debug(x...) LOG_LINE(_LOG_DEBUG, x)
 #define log_info(x...) LOG_LINE(_LOG_INFO, x)
--- LVM2/lib/metadata/metadata.c	2009/12/11 13:14:44	1.302
+++ LVM2/lib/metadata/metadata.c	2009/12/16 19:22:12	1.303
@@ -2107,7 +2107,7 @@
 				if (!id_write_format(&pvl->pv->id, uuid,
 						     sizeof(uuid)))
 					 stack;
-				log_error("Internal error: Duplicate PV id "
+				log_error(INTERNAL_ERROR "Duplicate PV id "
 					  "%s detected for %s in %s.",
 					  uuid, pv_dev_name(pvl->pv),
 					  vg->name);
@@ -2116,14 +2116,14 @@
 		}
 
 		if (strcmp(pvl->pv->vg_name, vg->name)) {
-			log_error("Internal error: VG name for PV %s is corrupted",
+			log_error(INTERNAL_ERROR "VG name for PV %s is corrupted",
 				  pv_dev_name(pvl->pv));
 			r = 0;
 		}
 	}
 
 	if (!check_pv_segments(vg)) {
-		log_error("Internal error: PV segments corrupted in %s.",
+		log_error(INTERNAL_ERROR "PV segments corrupted in %s.",
 			  vg->name);
 		r = 0;
 	}
@@ -2159,7 +2159,7 @@
 	 */
 	if (((uint32_t) dm_list_size(&vg->lvs)) !=
 	    vg_visible_lvs(vg) + snapshot_count(vg) + hidden_lv_count) {
-		log_error("Internal error: #internal LVs (%u) != #LVs (%"
+		log_error(INTERNAL_ERROR "#internal LVs (%u) != #LVs (%"
 			  PRIu32 ") + #snapshots (%" PRIu32 ") + #internal LVs %u in VG %s",
 			  dm_list_size(&vg->lvs), vg_visible_lvs(vg),
 			  snapshot_count(vg), hidden_lv_count, vg->name);
@@ -2171,7 +2171,7 @@
 			if (lvl == lvl2)
 				break;
 			if (!strcmp(lvl->lv->name, lvl2->lv->name)) {
-				log_error("Internal error: Duplicate LV name "
+				log_error(INTERNAL_ERROR "Duplicate LV name "
 					  "%s detected in %s.", lvl->lv->name,
 					  vg->name);
 				r = 0;
@@ -2181,7 +2181,7 @@
 				if (!id_write_format(&lvl->lv->lvid.id[1], uuid,
 						     sizeof(uuid)))
 					 stack;
-				log_error("Internal error: Duplicate LV id "
+				log_error(INTERNAL_ERROR "Duplicate LV id "
 					  "%s detected for %s and %s in %s.",
 					  uuid, lvl->lv->name, lvl2->lv->name,
 					  vg->name);
@@ -2192,7 +2192,7 @@
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (!check_lv_segments(lvl->lv, 1)) {
-			log_error("Internal error: LV segments corrupted in %s.",
+			log_error(INTERNAL_ERROR "LV segments corrupted in %s.",
 				  lvl->lv->name);
 			r = 0;
 		}
@@ -2200,7 +2200,7 @@
 
 	if (!(vg->fid->fmt->features & FMT_UNLIMITED_VOLS) &&
 	    (!vg->max_lv || !vg->max_pv)) {
-		log_error("Internal error: Volume group %s has limited PV/LV count"
+		log_error(INTERNAL_ERROR "Volume group %s has limited PV/LV count"
 			  " but limit is not set.", vg->name);
 		r = 0;
 	}
@@ -2311,7 +2311,7 @@
 	int failed = 0;
 
 	if (!vgname_is_locked(vg->name)) {
-		log_error("Internal error: Attempt to write new VG metadata "
+		log_error(INTERNAL_ERROR "Attempt to write new VG metadata "
 			  "without locking %s", vg->name);
 		return cache_updated;
 	}
@@ -2491,7 +2491,7 @@
 
 	if (is_orphan_vg(vgname)) {
 		if (use_precommitted) {
-			log_error("Internal error: vg_read_internal requires vgname "
+			log_error(INTERNAL_ERROR "vg_read_internal requires vgname "
 				  "with pre-commit.");
 			return NULL;
 		}
@@ -2802,7 +2802,7 @@
 		return NULL;
 
 	if (!check_pv_segments(vg)) {
-		log_error("Internal error: PV segments corrupted in %s.",
+		log_error(INTERNAL_ERROR "PV segments corrupted in %s.",
 			  vg->name);
 		vg_release(vg);
 		return NULL;
@@ -2810,7 +2810,7 @@
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (!check_lv_segments(lvl->lv, 1)) {
-			log_error("Internal error: LV segments corrupted in %s.",
+			log_error(INTERNAL_ERROR "LV segments corrupted in %s.",
 				  lvl->lv->name);
 			vg_release(vg);
 			return NULL;
@@ -2826,7 +2826,7 @@
 		return;
 
 	if (vg->cmd && vg->vgmem == vg->cmd->mem)
-		log_error("Internal error: global memory pool used for VG %s",
+		log_error(INTERNAL_ERROR "global memory pool used for VG %s",
 			  vg->name);
 
 	dm_pool_destroy(vg->vgmem);
@@ -3520,6 +3520,7 @@
 
 	/* Found vgname so cannot reserve. */
 	unlock_vg(cmd, vgname);
+	log_error("A volume group called '%s' already exists.", vg_name);
 	return FAILED_EXIST;
 }
 
--- LVM2/lib/mm/memlock.c	2009/11/19 01:11:57	1.14
+++ LVM2/lib/mm/memlock.c	2009/12/16 19:22:12	1.15
@@ -144,7 +144,7 @@
 void memlock_dec(void)
 {
 	if (!_memlock_count)
-		log_error("Internal error: _memlock_count has dropped below 0.");
+		log_error(INTERNAL_ERROR "_memlock_count has dropped below 0.");
 	--_memlock_count;
 	_unlock_mem_if_possible();
 	log_debug("memlock_count dec to %d", _memlock_count);
@@ -167,7 +167,7 @@
 void memlock_dec_daemon(void)
 {
 	if (!_memlock_count_daemon)
-		log_error("Internal error: _memlock_count_daemon has dropped below 0.");
+		log_error(INTERNAL_ERROR "_memlock_count_daemon has dropped below 0.");
 	--_memlock_count_daemon;
 	_unlock_mem_if_possible();
 	log_debug("memlock_count_daemon dec to %d", _memlock_count_daemon);
--- LVM2/lib/striped/striped.c	2009/09/28 16:23:46	1.29
+++ LVM2/lib/striped/striped.c	2009/12/16 19:22:12	1.30
@@ -168,7 +168,7 @@
 				uint32_t *pvmove_mirror_count __attribute((unused)))
 {
 	if (!seg->area_count) {
-		log_error("Internal error: striped add_target_line called "
+		log_error(INTERNAL_ERROR "striped add_target_line called "
 			  "with no areas for %s.", seg->lv->name);
 		return 0;
 	}
--- LVM2/tools/lvm.c	2008/12/18 05:27:18	1.110
+++ LVM2/tools/lvm.c	2009/12/16 19:22:13	1.111
@@ -237,7 +237,7 @@
 				  argv[0]);
 
                 if ((ret != ECMD_PROCESSED) && !error_message_produced()) {
-			log_debug("Internal error: Failed command did not use log_error");
+			log_debug(INTERNAL_ERROR "Failed command did not use log_error");
 			log_error("Command failed with status code %d.", ret);
 		}
 		_write_history();
--- LVM2/tools/lvmcmdline.c	2009/11/03 15:50:44	1.108
+++ LVM2/tools/lvmcmdline.c	2009/12/16 19:22:13	1.109
@@ -1243,7 +1243,7 @@
 		ret = lvm_run_command(cmd, argc, argv);
 		if (ret != ECMD_PROCESSED) {
 			if (!error_message_produced()) {
-				log_debug("Internal error: Failed command did not use log_error");
+				log_debug(INTERNAL_ERROR "Failed command did not use log_error");
 				log_error("Command failed with status code %d.", ret);
 			}
 			break;
@@ -1368,7 +1368,7 @@
 		log_error("No such command.  Try 'help'.");
 
 	if ((ret != ECMD_PROCESSED) && !error_message_produced()) {
-		log_debug("Internal error: Failed command did not use log_error");
+		log_debug(INTERNAL_ERROR "Failed command did not use log_error");
 		log_error("Command failed with status code %d.", ret);
 	}
 


