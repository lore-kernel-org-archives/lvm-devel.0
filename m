From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 18 Dec 2014 16:31:21 +0000 (UTC)
Subject: master - report: properly set "undefined" reserved value for cache_policy field
Message-ID: <20141218163121.0097561165@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=da9da0d8c2201c244d06a713134e96d2a26a0db5
Commit:        da9da0d8c2201c244d06a713134e96d2a26a0db5
Parent:        028ff309472834e82fe4b849ea4c243feb5098b9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Dec 18 15:11:25 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Dec 18 15:21:21 2014 +0100

report: properly set "undefined" reserved value for cache_policy field

Use helper macros to handle reserved values and also define "undefined"
reserved value as:

FIELD_RESERVED_VALUE(cache_policy, cache_policy_undef, "", "", "undefined")

Which means:

 - print "" if the cache_policy value is undefined (the first name for this reserved value is "")
 - recognize "undefined" reserved name as synonym to ""
   (so statements like "lvs -S cache_policy=undefined" are still recognized)
---
 lib/report/report.c |    3 ++-
 lib/report/values.h |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 5397d45..417396c 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -291,7 +291,8 @@ static int _cache_policy_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (seg_is_cache(seg))
 		seg = first_seg(seg->pool_lv);
 	else
-		return _field_set_value(field, "", GET_FIRST_RESERVED_NAME(cache_policy_undef));
+		return _field_set_value(field, GET_FIRST_RESERVED_NAME(cache_policy_undef),
+					GET_FIELD_RESERVED_VALUE(cache_policy_undef));
 
 	if (seg->policy_name) {
 		if (!(cache_policy_name = dm_pool_strdup(mem, seg->policy_name))) {
diff --git a/lib/report/values.h b/lib/report/values.h
index 4e12294..4ea92bd 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -86,7 +86,7 @@ FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r_override, "", "read-only-o
 FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead_auto, "", &GET_TYPE_RESERVED_VALUE(num_undef_64), "auto")
 
 /* Reserved values for SEG fields */
-FIELD_RESERVED_VALUE(cache_policy, cache_policy_undef, "", "undefined", "undefined")
+FIELD_RESERVED_VALUE(cache_policy, cache_policy_undef, "", "", "", "undefined")
 /* TODO the following 2 need STR_LIST support for reserved values
 FIELD_RESERVED_VALUE(cache_settings, cache_settings_default, "", "default", "default")
 FIELD_RESERVED_VALUE(cache_settings, cache_settings_undef, "", "undefined", "undefined") */


