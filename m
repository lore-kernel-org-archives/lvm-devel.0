From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  2 Mar 2011 19:20:25 +0100
Subject: [PATCH 3/4] Use allog_vg for _free_vg in _pvsegs_sub_single
In-Reply-To: <cover.1299089601.git.zkabelac@redhat.com>
References: <cover.1299089601.git.zkabelac@redhat.com>
Message-ID: <5900aea795a418903c044cec95c2752e5a40b2a5.1299089601.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

For simplier review.

Switch to use alloc_vg function for allocation of VG struct.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/reporter.c |   25 +++++++++++--------------
 1 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index ebe85e7..b8f8e37 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -58,17 +58,9 @@ static int _pvsegs_sub_single(struct cmd_context *cmd,
 {
 	int ret = ECMD_PROCESSED;
 	struct lv_segment *seg = pvseg->lvseg;
-
-	struct volume_group _free_vg = {
-		.cmd = cmd,
-		.name = "",
-	};
-
-        if (!(_free_vg.vgmem = dm_pool_create("_free_vg", 10240)))
-		return ECMD_FAILED;
+	struct volume_group *_free_vg;
 
 	struct logical_volume _free_logical_volume = {
-		.vg = vg ?: &_free_vg,
 		.name = "",
 		.snapshot = NULL,
 		.status = VISIBLE_LV,
@@ -92,11 +84,15 @@ static int _pvsegs_sub_single(struct cmd_context *cmd,
 		.areas = NULL,
 	};
 
+	if (!(_free_vg = alloc_vg("free_vg", cmd, ""))) {
+		stack;
+		return ECMD_FAILED;
+	}
+
+	_free_logical_volume.vg = vg ?: _free_vg;
 	_free_lv_segment.segtype = get_segtype_from_string(cmd, "free");
 	_free_lv_segment.len = pvseg->len;
-	dm_list_init(&_free_vg.pvs);
-	dm_list_init(&_free_vg.lvs);
-	dm_list_init(&_free_vg.tags);
+
 	dm_list_init(&_free_lv_segment.tags);
 	dm_list_init(&_free_lv_segment.origin_list);
 	dm_list_init(&_free_logical_volume.tags);
@@ -109,8 +105,9 @@ static int _pvsegs_sub_single(struct cmd_context *cmd,
 		ret = ECMD_FAILED;
                 goto_out;
 	}
- out:
-	free_vg(&_free_vg);
+out:
+	free_vg(_free_vg);
+
 	return ret;
 }
 
-- 
1.7.4.1


