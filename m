From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Jan 2019 06:55:38 -0500
Subject: master - vdo: discard reduced area
Message-ID: <201901211155.x0LBtctn024506@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f1ad4b067962c36e6f8199a8c6d10496bd9fb3b7
Commit:        f1ad4b067962c36e6f8199a8c6d10496bd9fb3b7
Parent:        ca72d19691683266f14dac7ae2eac755eeda6586
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 21 12:20:07 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 21 12:53:16 2019 +0100

vdo: discard reduced area

Implement sending discard to reduced LV area.
---
 lib/metadata/lv_manip.c |   37 +++++++++++++++++++++++++++++++++++++
 1 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9ef568c..1825abe 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5570,6 +5570,8 @@ int lv_resize(struct logical_volume *lv,
 	int activated = 0;
 	int ret = 0;
 	int status;
+	struct device *dev;
+	char name[PATH_MAX];
 
 	if (lv_is_writecache(lv)) {
 		log_error("Resize not yet allowed on LVs with writecache attached.");
@@ -5695,6 +5697,41 @@ int lv_resize(struct logical_volume *lv,
 		activated = 1;
 	}
 
+	/* Send DISCARD/TRIM to reduced area of VDO volumes
+	 * TODO: enable thin and provide
+	 * TODO2: we need polling method */
+	if ((lp->resize == LV_REDUCE) && lv_is_vdo(lv)) {
+		if (dm_snprintf(name, sizeof(name), "%s%s/%s", lv->vg->cmd->dev_dir,
+				lv->vg->name, lv->name) < 0) {
+			log_error("Name too long - device not discarded (%s)", lv->name);
+			return 0;
+		}
+
+		if (!(dev = dev_cache_get(lv->vg->cmd, name, NULL))) {
+			log_error("%s: not found: device not discarded.", name);
+			return 0;
+		}
+
+		if (!dev_discard_max_bytes(cmd->dev_types, dev) ||
+		    !dev_discard_granularity(cmd->dev_types, dev)) {
+			log_error("%s: max bytes and granularity query fails.", name);
+			dev_destroy_file(dev);
+			return 0;
+		}
+
+		log_warn("WARNING: %s: Discarding %s at offset " FMTu64 ", please wait...",
+			 name, display_size(cmd, (uint64_t)(lv->le_count - lp->extents) * vg->extent_size),
+			 ((uint64_t)lp->extents * vg->extent_size) << SECTOR_SHIFT);
+
+		if (!dev_discard_blocks(dev, ((uint64_t)lp->extents * vg->extent_size) << SECTOR_SHIFT,
+					((uint64_t)(lv->le_count - lp->extents) * vg->extent_size) << SECTOR_SHIFT)) {
+			log_error("%s: discarding failed.", name);
+			dev_destroy_file(dev);
+			return 0;
+		}
+
+		dev_destroy_file(dev);
+	}
 	/*
 	 * If the LV is locked from activation, this lock call is a no-op.
 	 * Otherwise, this acquires a transient lock on the lv (not PERSISTENT).


