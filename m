From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 31 Mar 2016 10:22:09 +0000 (UTC)
Subject: master - thin: no thin-pool flush when reading metadata status
Message-ID: <20160331102209.BC34B60DDB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8bbec41bd482175ee61478bef65cc58c7e814abf
Commit:        8bbec41bd482175ee61478bef65cc58c7e814abf
Parent:        fe7ae37f5e4af4f73aee5439dbef93d4facfaadf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 30 10:16:41 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 31 12:15:47 2016 +0200

thin: no thin-pool flush when reading metadata status

Previous fix missed the fact the we do query for 'percent' with
seg value either set or unset (API overload...)
When 'seg' was unset, we still issue flush with status.
Fix it by cheking segtype by target_type.

As we check for segtype - we could also skip whole percentage
if the 'segtype' is unknown by code directly.

Reported-by: Ming-Hung Tsai <mingnus gmail com
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |   11 +++++------
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index dae6a10..3237e0a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.149 - 
 ==================================
+  Do not flush thin-pool when checking metadata fullness.
   Remove spurious error about no value in /sys/dev/block/major:minor/dm/uuid.
   Fix device mismatch detection for LV if persistent .cache file is used.
   Fix holder device not being found in /dev while sysfs has it during dev scan.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 5761ede..2696c56 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -884,20 +884,22 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 	char *params = NULL;
 	const struct dm_list *segh = lv ? &lv->segments : NULL;
 	struct lv_segment *seg = NULL;
-	struct segment_type *segtype;
 	int first_time = 1;
 	dm_percent_t percent = DM_PERCENT_INVALID;
-
 	uint64_t total_numerator = 0, total_denominator = 0;
+	struct segment_type *segtype;
 
 	*overall_percent = percent;
 
+	if (!(segtype = get_segtype_from_string(dm->cmd, target_type)))
+		return_0;
+
 	if (!(dmt = _setup_task(name, dlid, event_nr,
 				wait ? DM_DEVICE_WAITEVENT : DM_DEVICE_STATUS, 0, 0, 0)))
 		return_0;
 
 	/* No freeze on overfilled thin-pool, read existing slightly outdated data */
-	if (lv && lv_is_thin_pool(lv) &&
+	if (segtype_is_thin(segtype) &&
 	    !dm_task_no_flush(dmt))
 		log_warn("Can't set no_flush flag."); /* Non fatal */
 
@@ -926,9 +928,6 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 		if (!type || !params)
 			continue;
 
-		if (!(segtype = get_segtype_from_string(dm->cmd, target_type)))
-			continue;
-
 		if (strcmp(type, target_type)) {
 			/* If kernel's type isn't an exact match is it compatible? */
 			if (!segtype->ops->target_status_compatible ||


