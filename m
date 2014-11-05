From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  5 Nov 2014 14:33:33 +0000 (UTC)
Subject: master - cleanup: avoid dm_list size calc in common path
Message-ID: <20141105143333.DA09B60701@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=94e4d5fcf51abdfd42df9299109fbc9d22f2f92b
Commit:        94e4d5fcf51abdfd42df9299109fbc9d22f2f92b
Parent:        6e5790f2d24d798e217fc005522c07e06c97adc9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 4 23:06:21 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 5 15:30:59 2014 +0100

cleanup: avoid dm_list size calc in common path

Calculate dm_list_size only when there is not just a single
ont segment in list - so it's only counted on error path.
---
 lib/metadata/lv_manip.c |   31 ++++++++++++++++---------------
 1 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 30188e4..6292626 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -826,24 +826,25 @@ struct lv_segment *get_only_segment_using_this_lv(const struct logical_volume *l
 		return NULL;
 	}
 
-	if (dm_list_size(&lv->segs_using_this_lv) != 1) {
-		log_error("%s is expected to have only one segment using it, "
-			  "while it has %d", lv->name,
-			  dm_list_size(&lv->segs_using_this_lv));
-		return NULL;
-	}
+	dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
+		/* Needs to be he only item in list */
+		if (!dm_list_end(&lv->segs_using_this_lv, &sl->list))
+			break;
 
-	dm_list_iterate_items(sl, &lv->segs_using_this_lv)
-		break; /* first item */
+		if (sl->count != 1) {
+			log_error("%s is expected to have only one segment using it, "
+				  "while %s:%" PRIu32 " uses it %d times.",
+				  display_lvname(lv), sl->seg->lv->name, sl->seg->le, sl->count);
+			return NULL;
+		}
 
-	if (sl->count != 1) {
-		log_error("%s is expected to have only one segment using it, "
-			  "while %s:%" PRIu32 " uses it %d times",
-			  lv->name, sl->seg->lv->name, sl->seg->le, sl->count);
-		return NULL;
+		return sl->seg;
 	}
 
-	return sl->seg;
+	log_error("%s is expected to have only one segment using it, while it has %d.",
+		  display_lvname(lv), dm_list_size(&lv->segs_using_this_lv));
+
+	return NULL;
 }
 
 /*


