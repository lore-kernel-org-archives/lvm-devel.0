From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 30 Sep 2013 07:00:17 +0000 (UTC)
Subject: master - thin: better dbg msgs and avoid uninit. value on chunk size recalc
Message-ID: <20130930070017.71B9E615DF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=24ffd5244feca36ef26d4c1453ee680508466475
Commit:        24ffd5244feca36ef26d4c1453ee680508466475
Parent:        e02ff3226021ddaf0861f65637d9be65d855506b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Sep 30 08:58:57 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Sep 30 08:58:57 2013 +0200

thin: better dbg msgs and avoid uninit. value on chunk size recalc

---
 lib/metadata/lv_manip.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 3789566..71b5278 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5539,7 +5539,7 @@ static int _recalculate_thin_pool_chunk_size_with_dev_hints(struct lvcreate_para
 	struct lv_segment *seg;
 	struct physical_volume *pv;
 	struct cmd_context *cmd = pool_lv->vg->cmd;
-	unsigned long previous_hint = 0, hint;
+	unsigned long previous_hint = 0, hint = 0;
 	uint32_t chunk_size = lp->chunk_size;
 	uint32_t default_chunk_size = lp->thin_chunk_size_calc_method == THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE ?
 					DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE*2 : DEFAULT_THIN_POOL_CHUNK_SIZE*2;
@@ -5564,11 +5564,18 @@ static int _recalculate_thin_pool_chunk_size_with_dev_hints(struct lvcreate_para
 		previous_hint = hint;
 	}
 
+	if (!hint) {
+		log_debug_alloc("No usable device hint found while recalculating "
+				"thin pool chunk size for %s.", pool_lv->name);
+		goto out;
+	}
+
 	if (hint < DM_THIN_MIN_DATA_BLOCK_SIZE ||
 	    hint > DM_THIN_MAX_DATA_BLOCK_SIZE) {
-		log_debug_alloc("Calculated value of %ld sectors for thin pool "
-				"chunk size is out of allowed range (%d-%d).",
-				hint, DM_THIN_MIN_DATA_BLOCK_SIZE, DM_THIN_MAX_DATA_BLOCK_SIZE);
+		log_debug_alloc("Calculated chunk size value of %ld sectors "
+				"for thin pool %s is out of allowed range (%d-%d).",
+				hint, pool_lv->name, DM_THIN_MIN_DATA_BLOCK_SIZE,
+				DM_THIN_MAX_DATA_BLOCK_SIZE);
 	} else
 		chunk_size = hint >= default_chunk_size ? hint : default_chunk_size;
 out:


