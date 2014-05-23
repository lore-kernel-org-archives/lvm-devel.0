From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 23 May 2014 19:38:43 +0000 (UTC)
Subject: master - dev_manager: disable extra udev loop
Message-ID: <20140523193843.F2F3A6112A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cb7bba9ffe48cecaf92912d04255171bf2f79bf6
Commit:        cb7bba9ffe48cecaf92912d04255171bf2f79bf6
Parent:        ec9da34d86f7d573b3925b0f33ed9d19afa4d846
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 23 21:22:38 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 23 21:36:55 2014 +0200

dev_manager: disable extra udev loop

Disable code which has postprocessed whole tree and reset udev flags.
We need to find out which case was troublesome - since this loop
was just hidding bug in other code parts (most probably preload tree)
---
 lib/activate/dev_manager.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index fb9625d..cfceab5 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2436,6 +2436,7 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 	return 1;
 }
 
+#if 0
 static int _set_udev_flags_for_children(struct dev_manager *dm,
 					struct volume_group *vg,
 					struct dm_tree_node *dnode)
@@ -2486,6 +2487,7 @@ static int _set_udev_flags_for_children(struct dev_manager *dm,
 
 	return 1;
 }
+#endif
 
 static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 				struct logical_volume *lv, struct lv_activate_opts *laopts,
@@ -2648,8 +2650,11 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			if (!_add_new_lv_to_dtree(dm, dtree, sl->seg->lv, laopts, NULL))
 				return_0;
 
+#if 0
+	/* Should not be needed, will be removed */
 	if (!_set_udev_flags_for_children(dm, lv->vg, dnode))
 		return_0;
+#endif
 
 	return 1;
 }


