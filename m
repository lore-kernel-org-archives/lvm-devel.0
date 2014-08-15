From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 15 Aug 2014 13:44:07 +0000 (UTC)
Subject: master - cleanup: gcc warning
Message-ID: <20140815134407.4EB0160EB1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8af23092310aeb02282f5082fba447586a1da0d3
Commit:        8af23092310aeb02282f5082fba447586a1da0d3
Parent:        8e449ebd63228bb8728d7e62989dc1254138b153
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Aug 15 15:43:42 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Aug 15 15:43:42 2014 +0200

cleanup: gcc warning

One more:

metadata/thin_manip.c:503: warning: declaration of "snapshot_count" shadows a global declaration
---
 lib/metadata/thin_manip.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index b4da500..ae42da1 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -500,13 +500,13 @@ const char *get_pool_discards_name(thin_discards_t discards)
 	return "unknown";
 }
 
-int lv_is_thin_origin(const struct logical_volume *lv, unsigned int *snapshot_count)
+int lv_is_thin_origin(const struct logical_volume *lv, unsigned int *snap_count)
 {
 	struct seg_list *segl;
 	int r = 0;
 
-	if (snapshot_count)
-		*snapshot_count = 0;
+	if (snap_count)
+		*snap_count = 0;
 
 	if (!lv_is_thin_volume(lv) ||
 	    dm_list_empty(&lv->segs_using_this_lv))
@@ -515,8 +515,8 @@ int lv_is_thin_origin(const struct logical_volume *lv, unsigned int *snapshot_co
 	dm_list_iterate_items(segl, &lv->segs_using_this_lv) {
 		if (segl->seg->origin == lv) {
 			r = 1;
-			if (snapshot_count)
-				(*snapshot_count)++;
+			if (snap_count)
+				(*snap_count)++;
 			else
 				/* not interested in number of snapshots */
 				break;


