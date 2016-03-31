From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 31 Mar 2016 10:22:11 +0000 (UTC)
Subject: master - thin: display highest mapped sector
Message-ID: <20160331102211.D253360DEB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fc7dacaa4c6bf0af4c5a457c098da26d7cc71f9c
Commit:        fc7dacaa4c6bf0af4c5a457c098da26d7cc71f9c
Parent:        8bbec41bd482175ee61478bef65cc58c7e814abf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 30 11:14:13 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 31 12:20:43 2016 +0200

thin: display highest mapped sector

Use  meta%  to expose highest mapped sector in thinLV.
so showing there 100.00% means thinLV maps latest sector.

Currently using a 'trick' with total_numerator to pass-in
device size when  'seg==NULL'

TODO: Improve device status API per target - current 'percentage'
is not really extensible.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |    4 ++++
 lib/thin/thin.c            |   15 +++++++++------
 3 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3237e0a..2ad2d69 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.149 - 
 ==================================
+  Report highest mapping for thin volume as Meta%.
   Do not flush thin-pool when checking metadata fullness.
   Remove spurious error about no value in /sys/dev/block/major:minor/dm/uuid.
   Fix device mismatch detection for LV if persistent .cache file is used.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 2696c56..40e4086 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -938,6 +938,10 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 		if (!segtype->ops->target_percent)
 			continue;
 
+		/* For thin volume pass device size via 'total_numerator' */
+		if (!seg && segtype_is_thin_volume(segtype))
+			total_numerator = length - 1; /* highest mapped is  0 .. (length - 1) */
+
 		if (!segtype->ops->target_percent(&dm->target_state,
 						  &percent, dm->mem,
 						  dm->cmd, seg, params,
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index a850757..c07859a 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -613,7 +613,7 @@ static int _thin_add_target_line(struct dev_manager *dm,
 static int _thin_target_percent(void **target_state __attribute__((unused)),
 				dm_percent_t *percent,
 				struct dm_pool *mem,
-				struct cmd_context *cmd __attribute__((unused)),
+				struct cmd_context *cmd,
 				struct lv_segment *seg,
 				char *params,
 				uint64_t *total_numerator,
@@ -643,15 +643,18 @@ static int _thin_target_percent(void **target_state __attribute__((unused)),
 
 		*percent = dm_make_percent(s->mapped_sectors, csize);
 		*total_denominator += csize;
+		*total_numerator += s->mapped_sectors;
 	} else {
-		/* No lv_segment info here */
-		*percent = DM_PERCENT_INVALID;
-		/* FIXME: Using denominator to pass the mapped info upward? */
+		/* Using denominator to pass the mapped info upward? */
+		if (s->highest_mapped_sector > *total_numerator) {
+			log_warn("WARNING: highest mapped sector %s is above device size.",
+				 display_size(cmd, s->highest_mapped_sector));
+			s->highest_mapped_sector = *total_numerator;
+		}
+		*percent = dm_make_percent(s->highest_mapped_sector, *total_numerator);
 		*total_denominator += s->highest_mapped_sector;
 	}
 
-	*total_numerator += s->mapped_sectors;
-
 	return 1;
 }
 


