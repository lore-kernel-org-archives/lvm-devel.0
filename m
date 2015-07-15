From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 15 Jul 2015 11:10:55 +0000 (UTC)
Subject: master - cache: enhance cache-pool validation
Message-ID: <20150715111055.349D8609E2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c2d4330f27277717bc3b684b702189079b257b77
Commit:        c2d4330f27277717bc3b684b702189079b257b77
Parent:        077645476cdfd7de0a16c283712b6c01938015d7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 14 09:58:37 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 15 13:10:22 2015 +0200

cache: enhance cache-pool validation

Capture cache-pool without cache policy name set.
---
 lib/metadata/merge.c |    6 ++++++
 lib/report/report.c  |   15 +++++----------
 2 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 7fd5a07..530b4e4 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -208,6 +208,12 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 				}
 
 			}
+			if (seg_is_cache_pool(seg)) {
+				if (!seg->policy_name) {
+					log_error("LV %s is missing cache policy name.", lv->name);
+					inc_error_count;
+				}
+			}
 			if (seg_is_pool(seg)) {
 				if (seg->area_count != 1 ||
 				    seg_type(seg, 0) != AREA_LV) {
diff --git a/lib/report/report.c b/lib/report/report.c
index 79802b7..c2ab991 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1381,7 +1381,6 @@ static int _cache_policy_disp(struct dm_report *rh, struct dm_pool *mem,
 			      const void *data, void *private)
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
-	const char *cache_policy_name;
 
 	if (seg_is_cache(seg))
 		seg = first_seg(seg->pool_lv);
@@ -1389,16 +1388,12 @@ static int _cache_policy_disp(struct dm_report *rh, struct dm_pool *mem,
 		return _field_set_value(field, GET_FIRST_RESERVED_NAME(cache_policy_undef),
 					GET_FIELD_RESERVED_VALUE(cache_policy_undef));
 
-	if (seg->policy_name) {
-		if (!(cache_policy_name = dm_pool_strdup(mem, seg->policy_name))) {
-			log_error("dm_pool_strdup failed");
-			return 0;
-		}
-		return _field_set_value(field, cache_policy_name, NULL);
-	} else {
-		log_error(INTERNAL_ERROR "unexpected NULL policy name");
-		return_0;
+	if (!seg->policy_name) {
+		log_error(INTERNAL_ERROR "Unexpected NULL policy name.");
+		return 0;
 	}
+
+	return _field_set_value(field, seg->policy_name, NULL);
 }
 
 static int _modules_disp(struct dm_report *rh, struct dm_pool *mem,


