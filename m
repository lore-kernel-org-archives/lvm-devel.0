From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 30 Nov 2009 12:37:11 +0100
Subject: [PATCH 11/23] Replicator: extend _lv_each_dependency() rep. deps
In-Reply-To: <1259581043-15308-11-git-send-email-zkabelac@redhat.com>
References: <1259581043-15308-1-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-2-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-3-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-4-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-5-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-6-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-7-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-8-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-9-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-10-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-11-git-send-email-zkabelac@redhat.com>
Message-ID: <1259581043-15308-12-git-send-email-zkabelac@redhat.com>
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
index 09ac62d..ce886a4 100644
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


