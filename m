From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jun 2019 17:08:34 -0400
Subject: master - move wipe_outdated_pvs to vg_write
Message-ID: <201906072108.x57L8Y09005293@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ab61a6d85da4e4f1d540e40ebac77999bf3c9a57
Commit:        ab61a6d85da4e4f1d540e40ebac77999bf3c9a57
Parent:        45b164f62cae25da3ac4b9f0d4f87ecaee1575fa
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 6 12:32:26 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 7 15:54:04 2019 -0500

move wipe_outdated_pvs to vg_write

and implement it based on a device, not based
on a pv struct (which is not available when the
device is not a part of the vg.)

currently only the vgremove command wipes outdated
pvs until more advanced recovery is added in a
subsequent commit
---
 lib/commands/toolcontext.h    |    1 +
 lib/format_text/format-text.c |   33 +++++++++++
 lib/format_text/format-text.h |    3 +
 lib/metadata/metadata.c       |  123 +++++++++++++++++++++++------------------
 tools/vgremove.c              |    2 +
 5 files changed, 109 insertions(+), 53 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 7d373ab..6e4530c 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -179,6 +179,7 @@ struct cmd_context {
 	unsigned use_hints:1;			/* if hints are enabled this cmd can use them */
 	unsigned pvscan_recreate_hints:1;	/* enable special case hint handling for pvscan --cache */
 	unsigned scan_lvs:1;
+	unsigned wipe_outdated_pvs:1;
 
 	/*
 	 * Devices and filtering.
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 9d58c53..6e224f0 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2463,3 +2463,36 @@ bad:
 
 	return NULL;
 }
+
+int text_wipe_outdated_pv_mda(struct cmd_context *cmd, struct device *dev,
+			      struct metadata_area *mda)
+{
+	struct mda_context *mdac = mda->metadata_locn;
+	uint64_t start_byte = mdac->area.start;
+	struct mda_header *mdab;
+	struct raw_locn *rlocn_slot0;
+	struct raw_locn *rlocn_slot1;
+	uint32_t bad_fields = 0;
+
+	if (!(mdab = raw_read_mda_header(cmd->fmt, &mdac->area, mda_is_primary(mda), 0, &bad_fields))) {
+		log_error("Failed to read outdated pv mda header on %s", dev_name(dev));
+		return 0;
+	}
+
+	rlocn_slot0 = &mdab->raw_locns[0];
+	rlocn_slot1 = &mdab->raw_locns[1];
+
+	rlocn_slot0->offset = 0;
+	rlocn_slot0->size = 0;
+	rlocn_slot0->checksum = 0;
+	rlocn_slot1->offset = 0;
+	rlocn_slot1->size = 0;
+	rlocn_slot1->checksum = 0;
+         
+	if (!_raw_write_mda_header(cmd->fmt, dev, mda_is_primary(mda), start_byte, mdab)) {
+		log_error("Failed to write outdated pv mda header on %s", dev_name(dev));
+		return 0;
+	}
+
+	return 1;
+}
diff --git a/lib/format_text/format-text.h b/lib/format_text/format-text.h
index c42d5c0..2345d52 100644
--- a/lib/format_text/format-text.h
+++ b/lib/format_text/format-text.h
@@ -77,4 +77,7 @@ struct data_area_list {
 	struct disk_locn disk_locn;
 };
 
+int text_wipe_outdated_pv_mda(struct cmd_context *cmd, struct device *dev,
+                              struct metadata_area *mda);
+
 #endif
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index bd6ec4d..a13be57 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -28,11 +28,14 @@
 #include "lib/display/display.h"
 #include "lib/locking/locking.h"
 #include "lib/format_text/archiver.h"
+#include "lib/format_text/format-text.h"
+#include "lib/format_text/layout.h"
+#include "lib/format_text/import-export.h"
 #include "lib/config/defaults.h"
 #include "lib/locking/lvmlockd.h"
-#include "time.h"
 #include "lib/notify/lvmnotify.h"
 
+#include <time.h>
 #include <math.h>
 
 static struct physical_volume *_pv_read(struct cmd_context *cmd,
@@ -2922,6 +2925,69 @@ static int _handle_historical_lvs(struct volume_group *vg)
 	return 1;
 }
 
+static void _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg)
+{
+	struct dm_list devs;
+	struct dm_list *mdas = NULL;
+	struct device_list *devl;
+	struct device *dev;
+	struct metadata_area *mda;
+	struct label *label;
+	struct lvmcache_info *info;
+	uint32_t ext_flags;
+
+	dm_list_init(&devs);
+
+	/*
+	 * When vg_read selected a good copy of the metadata, it used it to
+	 * update the lvmcache representation of the VG (lvmcache_update_vg).
+	 * At that point outdated PVs were recognized and moved into the
+	 * vginfo->outdated_infos list.  Here we clear the PVs on that list.
+	 */
+
+	lvmcache_get_outdated_devs(cmd, vg->name, (const char *)&vg->id, &devs);
+
+	dm_list_iterate_items(devl, &devs) {
+		dev = devl->dev;
+
+		lvmcache_get_outdated_mdas(cmd, vg->name, (const char *)&vg->id, dev, &mdas);
+
+		if (mdas) {
+			dm_list_iterate_items(mda, mdas) {
+				log_warn("WARNING: wiping mda on outdated PV %s", dev_name(dev));
+
+				if (!text_wipe_outdated_pv_mda(cmd, dev, mda))
+					log_warn("WARNING: failed to wipe mda on outdated PV %s", dev_name(dev));
+			}
+		}
+
+		if (!(label = lvmcache_get_dev_label(dev))) {
+			log_error("_wipe_outdated_pvs no label for %s", dev_name(dev));
+			continue;
+		}
+
+		info = label->info;
+		ext_flags = lvmcache_ext_flags(info);
+		ext_flags &= ~PV_EXT_USED;
+		lvmcache_set_ext_version(info, PV_HEADER_EXTENSION_VSN);
+		lvmcache_set_ext_flags(info, ext_flags);
+
+		log_warn("WARNING: wiping header on outdated PV %s", dev_name(dev));
+
+		if (!label_write(dev, label))
+			log_warn("WARNING: failed to wipe header on outdated PV %s", dev_name(dev));
+
+		lvmcache_del(info);
+	}
+
+	/*
+	 * A vgremove will involve many vg_write() calls (one for each lv
+	 * removed) but we only need to wipe pvs once, so clear the outdated
+	 * list so it won't be wiped again.
+	 */
+	lvmcache_del_outdated_devs(cmd, vg->name, (const char *)&vg->id);
+}
+
 /*
  * After vg_write() returns success,
  * caller MUST call either vg_commit() or vg_revert()
@@ -2986,6 +3052,9 @@ int vg_write(struct volume_group *vg)
 		return 0;
 	}
 
+	if (vg->cmd->wipe_outdated_pvs)
+		_wipe_outdated_pvs(vg->cmd, vg);
+
 	if (critical_section())
 		log_error(INTERNAL_ERROR
 			  "Writing metadata in critical section.");
@@ -3538,52 +3607,6 @@ static int _repair_inconsistent_vg(struct volume_group *vg, uint32_t lockd_state
 	return 1;
 }
 
-static int _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg, struct dm_list *to_check, uint32_t lockd_state)
-{
-	struct pv_list *pvl, *pvl2;
-	char uuid[64] __attribute__((aligned(8)));
-
-	if (lvmcache_found_duplicate_pvs()) {
-		log_debug_metadata("Skip wiping outdated PVs with duplicates.");
-		return 0;
-	}
-
-	/*
-	 * Cannot write foreign VGs, the owner will repair it.
-	 * Also, if another host is updating its VG, we may read
-	 * the PVs while some are written but not others, making
-	 * some PVs look outdated to us just because we're reading
-	 * the VG while it's only partially written out.
-	 */
-	if (_is_foreign_vg(vg)) {
-		log_debug_metadata("Skip wiping outdated PVs for foreign VG.");
-		return 0;
-	}
-
-	if (vg_is_shared(vg) && !(lockd_state & LDST_EX)) {
-		log_verbose("Skip wiping outdated PVs for shared VG without exclusive lock.");
-		return 0;
-	}
-
-	dm_list_iterate_items(pvl, to_check) {
-		dm_list_iterate_items(pvl2, &vg->pvs) {
-			if (pvl->pv->dev == pvl2->pv->dev)
-				goto next_pv;
-		}
-
-
-		if (!id_write_format(&pvl->pv->id, uuid, sizeof(uuid)))
-			return_0;
-		log_warn("WARNING: Removing PV %s (%s) that no longer belongs to VG %s",
-			 pv_dev_name(pvl->pv), uuid, vg->name);
-		if (!pv_write_orphan(cmd, pvl->pv))
-			return_0;
-next_pv:
-		;
-	}
-	return 1;
-}
-
 static int _check_or_repair_pv_ext(struct cmd_context *cmd,
 				   struct volume_group *vg,
 				   uint32_t lockd_state,
@@ -4217,12 +4240,6 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			release_vg(correct_vg);
 			return NULL;
 		}
-
-		if (!_wipe_outdated_pvs(cmd, correct_vg, &all_pvs, lockd_state)) {
-			_free_pv_list(&all_pvs);
-			release_vg(correct_vg);
-			return_NULL;
-		}
 	}
 
 	_free_pv_list(&all_pvs);
diff --git a/tools/vgremove.c b/tools/vgremove.c
index 1aae87d..23640f6 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -99,6 +99,8 @@ int vgremove(struct cmd_context *cmd, int argc, char **argv)
 
 	clear_hint_file(cmd);
 
+	cmd->wipe_outdated_pvs = 1;
+
 	cmd->handles_missing_pvs = 1;
 	ret = process_each_vg(cmd, argc, argv, NULL, NULL,
 			      READ_FOR_UPDATE, 0,


