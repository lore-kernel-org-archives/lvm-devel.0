From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Feb 2014 21:26:38 +0000 (UTC)
Subject: master - cleanup: indent
Message-ID: <20140217212638.3F05660C84@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9974136b907962438079e4c634541f97d1f9fd61
Commit:        9974136b907962438079e4c634541f97d1f9fd61
Parent:        25cea92338876f7ed02b05652a2de3f28c9bae1c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 17 21:49:51 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 17 22:25:53 2014 +0100

cleanup: indent

---
 lib/activate/dev_manager.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index fe36149..6b5f8c2 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2506,7 +2506,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		     dinfo->open_count)) {
 			if (seg_is_thin_volume(seg) ||
 			    /* FIXME Is there anything simpler to check for instead? */
-                            !lv_has_target_type(dm->mem, lv, NULL, "snapshot-merge"))
+			    !lv_has_target_type(dm->mem, lv, NULL, "snapshot-merge"))
 				laopts->no_merging = 1;
 		}
 	}
@@ -2562,7 +2562,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			return_0;
 		if (!laopts->no_merging && lv_is_merging_origin(lv)) {
 			if (!_add_new_lv_to_dtree(dm, dtree,
-			     find_snapshot(lv)->cow, laopts, "cow"))
+						  find_snapshot(lv)->cow, laopts, "cow"))
 				return_0;
 			/*
 			 * Must also add "real" LV for use when


