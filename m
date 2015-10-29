From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 29 Oct 2015 11:39:43 +0000 (UTC)
Subject: master - cleanup: easier error messages
Message-ID: <20151029113943.99DBF60E62@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f32f0bd2a7aeddb90d41f342d4213ef054e9d4fd
Commit:        f32f0bd2a7aeddb90d41f342d4213ef054e9d4fd
Parent:        99237f0908d87592815f4bdf3c239e8a108e835c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 29 11:01:24 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 29 12:14:20 2015 +0100

cleanup: easier error messages

---
 lib/thin/thin.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index d042473..ad400ef 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -279,20 +279,20 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 
 	if (!(attr & THIN_FEATURE_BLOCK_SIZE) &&
 	    (seg->chunk_size & (seg->chunk_size - 1))) {
-		log_error("Thin pool target does not support %uKiB chunk size "
-			  "(needs kernel >= 3.6).", seg->chunk_size / 2);
+		log_error("Thin pool target does not support %s chunk size (needs"
+			  " kernel >= 3.6).", display_size(cmd, seg->chunk_size));
 		return 0;
 	}
 
 	if (!(metadata_dlid = build_dm_uuid(mem, seg->metadata_lv, NULL))) {
 		log_error("Failed to build uuid for metadata LV %s.",
-			  seg->metadata_lv->name);
+			  display_lvname(seg->metadata_lv));
 		return 0;
 	}
 
 	if (!(pool_dlid = build_dm_uuid(mem, seg_lv(seg, 0), NULL))) {
 		log_error("Failed to build uuid for pool LV %s.",
-			  seg_lv(seg, 0)->name);
+			  display_lvname(seg_lv(seg, 0)));
 		return 0;
 	}
 


