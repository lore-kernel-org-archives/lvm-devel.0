From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 13 Jan 2010 14:35:52 +0100
Subject: [PATCH 1/6] Do not create generate lvol%d name
In-Reply-To: <cover.1263389392.git.zkabelac@redhat.com>
References: <cover.1263389392.git.zkabelac@redhat.com>
Message-ID: <4a2e67689748d54ef54eaa2e4a4de824da3cc771.1263389392.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvol%d is generated for NULL name in lv_create_empty().
So just avoid code duplication.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/lv_manip.c |   14 +-------------
 1 files changed, 1 insertions(+), 13 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8c0ecf9..57c3d08 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2852,8 +2852,6 @@ int lv_create_single(struct volume_group *vg,
 	uint64_t status = UINT64_C(0);
 	struct logical_volume *lv, *org = NULL;
 	int origin_active = 0;
-	char lv_name_buf[128];
-	const char *lv_name;
 	struct lvinfo info;
 
 	if (lp->lv_name && find_lv_in_vg(vg, lp->lv_name)) {
@@ -3008,16 +3006,6 @@ int lv_create_single(struct volume_group *vg,
 	if (!archive(vg))
 		return 0;
 
-	if (lp->lv_name)
-		lv_name = lp->lv_name;
-	else {
-		if (!generate_lv_name(vg, "lvol%d", lv_name_buf, sizeof(lv_name_buf))) {
-			log_error("Failed to generate LV name.");
-			return 0;
-		}
-		lv_name = &lv_name_buf[0];
-	}
-
 	if (lp->tag) {
 		if (!(vg->fid->fmt->features & FMT_TAGS)) {
 			log_error("Volume group %s does not support tags",
@@ -3036,7 +3024,7 @@ int lv_create_single(struct volume_group *vg,
 		}
 	}
 
-	if (!(lv = lv_create_empty(lv_name ? lv_name : "lvol%d", NULL,
+	if (!(lv = lv_create_empty(lp->lv_name ? lp->lv_name : "lvol%d", NULL,
 				   status, lp->alloc, vg)))
 		return_0;
 
-- 
1.6.6


