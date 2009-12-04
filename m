From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  4 Dec 2009 15:04:45 +0100
Subject: [PATCH 08/22] Replicator: extend _lv_each_dependency() rep. deps
In-Reply-To: <cover.1259934415.git.zkabelac@redhat.com>
References: <cover.1259934415.git.zkabelac@redhat.com>
Message-ID: <53e83d22421e1b0fa6975df4776933cea1ae19ac.1259934415.git.zkabelac@redhat.com>
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
index 5b46c25..9869a3c 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1927,6 +1927,8 @@ static int _lv_each_dependency(struct logical_volume *lv,
 	struct lv_segment *lvseg;
 
 	struct logical_volume *deps[] = {
+		(lv->rdevice && lv != lv->rdevice->lv) ? lv->rdevice->lv : 0,
+		(lv->rdevice && lv != lv->rdevice->slog) ? lv->rdevice->slog : 0,
 		lv->snapshot ? lv->snapshot->origin : 0,
 		lv->snapshot ? lv->snapshot->cow : 0 };
 	for (i = 0; i < sizeof(deps) / sizeof(*deps); ++i) {
@@ -1937,6 +1939,8 @@ static int _lv_each_dependency(struct logical_volume *lv,
 	dm_list_iterate_items(lvseg, &lv->segments) {
 		if (lvseg->log_lv && !fn(lvseg->log_lv, data))
 			return_0;
+		if (lvseg->rlog_lv && !fn(lvseg->rlog_lv, data))
+			return_0;
 		for (s = 0; s < lvseg->area_count; ++s) {
 			if (seg_type(lvseg, s) == AREA_LV && !fn(seg_lv(lvseg,s), data))
 				return_0;
-- 
1.6.5.3


