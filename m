From: Alasdair Kergon <agk@sourceware.org>
Date: Fri, 27 Oct 2017 17:55:39 -0400
Subject: master - vgsplit: Fix detection of moved PVs.
Message-ID: <201710272155.v9RLtd9K007401@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=84aca4201e3588159e75fa8e047e997c2fad13d2
Commit:        84aca4201e3588159e75fa8e047e997c2fad13d2
Parent:        eb710cced11a290ebe3e365e3b1cc225920b6b99
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Oct 27 21:38:16 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Oct 27 22:53:43 2017 +0100

vgsplit: Fix detection of moved PVs.

vgsplit shares the vg_rename code so that must only set the PV_MOVED_VG
flag introduced in commit 486ed108481cfbe4336f0fa590cbae251188ecc6
("vgmerge: Fix intermediate metadata corruption") on PVs that moved.
---
 WHATS_NEW               |    1 +
 lib/config/config.c     |    2 +-
 lib/metadata/metadata.c |    8 +++++++-
 tools/vgmerge.c         |    1 +
 4 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fbf8732..3e13d8c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.176 -
 ===================================
+  Fix detection of moved PVs in vgsplit. (2.02.175)
   Ignore --stripes/--stripesize on RAID takeover
   Improve used paths for generated systemd units and init shells.
   Disallow creation of snapshot of mirror/raid subLV (was never supported).
diff --git a/lib/config/config.c b/lib/config/config.c
index 1f18969..e8e330b 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -542,7 +542,7 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 	if (checksum_fn && checksum !=
 	    (checksum_fn(checksum_fn(INITIAL_CRC, (const uint8_t *)fb, size),
 			 (const uint8_t *)(fb + size), size2))) {
-		log_error("%s: Checksum error", dev_name(dev));
+		log_error("%s: Checksum error at offset %" PRIu64, dev_name(dev), (uint64_t) offset);
 		goto out;
 	}
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index bcc23bc..2a9819d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -512,13 +512,19 @@ int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
+		/* Skip if VG didn't change e.g. with vgsplit */
+		if (pvl->pv->vg_name && !strcmp(new_name, pvl->pv->vg_name))
+			continue;
+
 		if (!(pvl->pv->vg_name = dm_pool_strdup(mem, new_name))) {
 			log_error("pv->vg_name allocation failed for '%s'",
 				  pv_dev_name(pvl->pv));
 			return 0;
 		}
+
                 /* Mark the PVs that still hold metadata with the old VG name */
-                pvl->pv->status |= PV_MOVED_VG;
+		log_debug_metadata("Marking PV %s as moved to VG %s", dev_name(pvl->pv->dev), new_name);
+		pvl->pv->status |= PV_MOVED_VG;
 	}
 
 	return 1;
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 86c6a48..013bef4 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -112,6 +112,7 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 		add_pvl_to_vgs(vg_to, pvl);
 		pvl->pv->vg_name = dm_pool_strdup(cmd->mem, vg_to->name);
 		/* Mark the VGs that still hold metadata for the old VG */
+		log_debug_metadata("Marking PV %s as moved to VG %s", dev_name(pvl->pv->dev), vg_to->name);
 		pvl->pv->status |= PV_MOVED_VG;
 	}
 


