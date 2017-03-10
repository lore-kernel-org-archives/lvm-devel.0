From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:37:41 -0500
Subject: master - cleanup: easier code
Message-ID: <201703101837.v2AIbf6q022449@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d11b8eef893b9bd05b2e923f8637e527df16ac01
Commit:        d11b8eef893b9bd05b2e923f8637e527df16ac01
Parent:        52935b5834b6592acab1e68df18b9779de54033f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 8 14:28:28 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:01 2017 +0100

cleanup: easier code

---
 lib/metadata/thin_manip.c |   20 ++++++++------------
 1 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index ce5b95c..d1259b4 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -781,20 +781,16 @@ int lv_is_thin_origin(const struct logical_volume *lv, unsigned int *snap_count)
 	if (snap_count)
 		*snap_count = 0;
 
-	if (!lv_is_thin_volume(lv) ||
-	    dm_list_empty(&lv->segs_using_this_lv))
-		return 0;
+	if (lv_is_thin_volume(lv))
+		dm_list_iterate_items(segl, &lv->segs_using_this_lv)
+			if (segl->seg->origin == lv) {
+				r = 1;
+
+				if (!snap_count)
+					break;/* not interested in number of snapshots */
 
-	dm_list_iterate_items(segl, &lv->segs_using_this_lv) {
-		if (segl->seg->origin == lv) {
-			r = 1;
-			if (snap_count)
 				(*snap_count)++;
-			else
-				/* not interested in number of snapshots */
-				break;
-		}
-	}
+			}
 
 	return r;
 }


