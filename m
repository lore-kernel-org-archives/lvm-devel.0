From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 26 Aug 2015 09:29:20 +0000 (UTC)
Subject: master - cache: report cache pool attrs also for pools
Message-ID: <20150826092920.2B17461188@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a4fdfc098d7a1c28793a8ba6f82277ecef40dfcd
Commit:        a4fdfc098d7a1c28793a8ba6f82277ecef40dfcd
Parent:        cbe81ad3932417ffaf89cbd924bd6d1ce1c7f199
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 25 15:07:41 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 26 11:24:41 2015 +0200

cache: report cache pool attrs also for pools

Since cache-pool actualy keeps info about caching,
display this info for cache-pool LV as well
(matches info for cache LV when cache-pool is asociated with it).
---
 WHATS_NEW           |    1 +
 lib/report/report.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4eb852c..ac8e1e9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.129 -
 ===================================
+  Fix and improve reporting properties of cache-pool.
   Enable usage of --cachepolicy and --cachesetting with lvconvert.
   Don't allow to reduce size of thin-pool metadata.
   Fix debug buffer overflows in cmirrord logging.
diff --git a/lib/report/report.c b/lib/report/report.c
index 1885f45..4fd311a 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1344,7 +1344,7 @@ static int _cache_settings_disp(struct dm_report *rh, struct dm_pool *mem,
 
 	if (seg_is_cache(seg))
 		seg = first_seg(seg->pool_lv);
-	else {
+	else if (!seg_is_cache_pool(seg)) {
 		dm_list_init(&dummy_list);
 		return _field_set_string_list(rh, field, &dummy_list, private, 0);
 		/* TODO: once we have support for STR_LIST reserved values, replace with:
@@ -1384,7 +1384,7 @@ static int _cache_policy_disp(struct dm_report *rh, struct dm_pool *mem,
 
 	if (seg_is_cache(seg))
 		seg = first_seg(seg->pool_lv);
-	else
+	else if (!seg_is_cache_pool(seg) || !seg->policy_name)
 		return _field_set_value(field, GET_FIRST_RESERVED_NAME(cache_policy_undef),
 					GET_FIELD_RESERVED_VALUE(cache_policy_undef));
 


