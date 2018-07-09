From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:35:11 -0400
Subject: master - vdo: data percentage
Message-ID: <201807091335.w69DZBk0030755@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=44c99a882299b4a6d6d675df3db5a6ef481fa2a0
Commit:        44c99a882299b4a6d6d675df3db5a6ef481fa2a0
Parent:        5807993bbfedfc7a7c58de082c92811109c02ea0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 4 23:17:38 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:28:35 2018 +0200

vdo: data percentage

Display percentage of used virtual size of vdo-pool volume.
---
 lib/activate/activate.c          |   15 +++++++++++++++
 lib/metadata/lv.c                |    5 ++++-
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/vdo_manip.c         |    4 ++++
 4 files changed, 24 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 0435139..28d67b4 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -798,6 +798,21 @@ int lv_info_with_seg_status(struct cmd_context *cmd,
 		lv_seg = find_snapshot(lv);
 	}
 
+	if (lv_is_vdo(lv)) {
+		if (!_lv_info(cmd, lv, 0, &status->info, NULL, NULL,
+			      with_open_count, with_read_ahead))
+			return_0;
+		if (status->info.exists) {
+			/* Status for VDO pool */
+			(void) _lv_info(cmd, seg_lv(lv_seg, 0), 1, NULL,
+					first_seg(seg_lv(lv_seg, 0)),
+					&status->seg_status, 0, 0);
+			/* Use VDO pool segtype result for VDO segtype */
+			status->seg_status.seg = lv_seg;
+		}
+		return 1;
+	}
+
 	return _lv_info(cmd, lv, 0, &status->info, lv_seg, &status->seg_status,
 			with_open_count, with_read_ahead);
 }
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index d8417bc..9c8b028 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -451,7 +451,10 @@ dm_percent_t lvseg_percent_with_info_and_seg_status(const struct lv_with_info_an
 		}
 		break;
 	case SEG_STATUS_VDO_POOL:
-		p = s->vdo_pool.usage;
+		if (seg_is_vdo_pool(lvdm->seg_status.seg))
+			p = s->vdo_pool.usage;
+		else
+			p = s->vdo_pool.data_usage;
 		break;
 	default:
 		p = DM_PERCENT_INVALID;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b6ac4cb..92def2b 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1257,6 +1257,7 @@ struct lv_status_vdo {
 	uint64_t logical_blocks_used;	/* grabbed from /sys/kvdo */
 	dm_percent_t usage;
 	dm_percent_t saving;
+	dm_percent_t data_usage;
 };
 
 const char *get_vdo_compression_state_name(enum dm_vdo_compression_state state);
diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index 5801a1b..1286e84 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -141,6 +141,7 @@ int parse_vdo_pool_status(struct dm_pool *mem, const struct logical_volume *vdo_
 
 	status->usage = DM_PERCENT_INVALID;
 	status->saving = DM_PERCENT_INVALID;
+	status->data_usage = DM_PERCENT_INVALID;
 
 	if (!(dm_name = dm_build_dm_name(mem, vdo_pool_lv->vg->name,
 					 vdo_pool_lv->name, NULL))) {
@@ -170,6 +171,9 @@ int parse_vdo_pool_status(struct dm_pool *mem, const struct logical_volume *vdo_
 						result.status->total_blocks);
 		status->saving = dm_make_percent(status->logical_blocks_used - status->data_blocks_used,
 						 status->logical_blocks_used);
+		status->data_usage = dm_make_percent(status->data_blocks_used * DM_VDO_BLOCK_SIZE,
+						     first_seg(vdo_pool_lv)->vdo_pool_virtual_extents *
+						     (uint64_t) vdo_pool_lv->vg->extent_size);
 	}
 
 	return 1;


