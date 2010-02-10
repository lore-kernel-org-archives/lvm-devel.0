From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 10 Feb 2010 15:56:51 +0100
Subject: [PATCH 05/19] Replicator: extend _lv_each_dependency() rep. deps
In-Reply-To: <cover.1265813098.git.zkabelac@redhat.com>
References: <cover.1265813098.git.zkabelac@redhat.com>
Message-ID: <c83876f361458e34ae1e5e4960fcb3361d1c5ba1.1265813098.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index f14647f..98f4987 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1921,6 +1921,8 @@ static int _lv_each_dependency(struct logical_volume *lv,
 	struct lv_segment *lvseg;
 
 	struct logical_volume *deps[] = {
+		(lv->rdevice && lv != lv->rdevice->lv) ? lv->rdevice->lv : 0,
+		(lv->rdevice && lv != lv->rdevice->slog) ? lv->rdevice->slog : 0,
 		lv->snapshot ? lv->snapshot->origin : 0,
 		lv->snapshot ? lv->snapshot->cow : 0 };
 	for (i = 0; i < sizeof(deps) / sizeof(*deps); ++i) {
@@ -1931,6 +1933,8 @@ static int _lv_each_dependency(struct logical_volume *lv,
 	dm_list_iterate_items(lvseg, &lv->segments) {
 		if (lvseg->log_lv && !fn(lvseg->log_lv, data))
 			return_0;
+		if (lvseg->rlog_lv && !fn(lvseg->rlog_lv, data))
+			return_0;
 		for (s = 0; s < lvseg->area_count; ++s) {
 			if (seg_type(lvseg, s) == AREA_LV && !fn(seg_lv(lvseg,s), data))
 				return_0;
-- 
1.6.6.1


