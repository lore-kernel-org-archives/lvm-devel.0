From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  1 Apr 2016 19:11:39 +0000 (UTC)
Subject: master - Revert "thin: display highest mapped sector"
Message-ID: <20160401191139.661F360FF4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=60befab7732d33bc29f796b6ff3743969b328240
Commit:        60befab7732d33bc29f796b6ff3743969b328240
Parent:        42f04a0f77ee94b01d652d6c11d10e85aa46a897
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Apr 1 20:09:38 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Apr 1 20:09:38 2016 +0100

Revert "thin: display highest mapped sector"

This reverts commit fc7dacaa4c6bf0af4c5a457c098da26d7cc71f9c.

Let's put this information into a separate field.  It doesn't meet the
definition of the existing field.
---
 WHATS_NEW                  |    1 -
 lib/activate/dev_manager.c |    4 ----
 lib/thin/thin.c            |   15 ++++++---------
 3 files changed, 6 insertions(+), 14 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2ad2d69..3237e0a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,5 @@
 Version 2.02.149 - 
 ==================================
-  Report highest mapping for thin volume as Meta%.
   Do not flush thin-pool when checking metadata fullness.
   Remove spurious error about no value in /sys/dev/block/major:minor/dm/uuid.
   Fix device mismatch detection for LV if persistent .cache file is used.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 5341b54..3563d5a 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -938,10 +938,6 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 		if (!segtype->ops->target_percent)
 			continue;
 
-		/* For thin volume pass device size via 'total_numerator' */
-		if (!seg && segtype_is_thin_volume(segtype))
-			total_numerator = length - 1; /* highest mapped is  0 .. (length - 1) */
-
 		if (!segtype->ops->target_percent(&dm->target_state,
 						  &percent, dm->mem,
 						  dm->cmd, seg, params,
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index c07859a..a850757 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -613,7 +613,7 @@ static int _thin_add_target_line(struct dev_manager *dm,
 static int _thin_target_percent(void **target_state __attribute__((unused)),
 				dm_percent_t *percent,
 				struct dm_pool *mem,
-				struct cmd_context *cmd,
+				struct cmd_context *cmd __attribute__((unused)),
 				struct lv_segment *seg,
 				char *params,
 				uint64_t *total_numerator,
@@ -643,18 +643,15 @@ static int _thin_target_percent(void **target_state __attribute__((unused)),
 
 		*percent = dm_make_percent(s->mapped_sectors, csize);
 		*total_denominator += csize;
-		*total_numerator += s->mapped_sectors;
 	} else {
-		/* Using denominator to pass the mapped info upward? */
-		if (s->highest_mapped_sector > *total_numerator) {
-			log_warn("WARNING: highest mapped sector %s is above device size.",
-				 display_size(cmd, s->highest_mapped_sector));
-			s->highest_mapped_sector = *total_numerator;
-		}
-		*percent = dm_make_percent(s->highest_mapped_sector, *total_numerator);
+		/* No lv_segment info here */
+		*percent = DM_PERCENT_INVALID;
+		/* FIXME: Using denominator to pass the mapped info upward? */
 		*total_denominator += s->highest_mapped_sector;
 	}
 
+	*total_numerator += s->mapped_sectors;
+
 	return 1;
 }
 


