From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Nov 2016 16:00:15 +0000 (UTC)
Subject: master - cleanup: debug trace and indent change
Message-ID: <20161111160015.2CD8160255@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a7691cdebb6333b8f35d6a5a1a7d18aad6536c23
Commit:        a7691cdebb6333b8f35d6a5a1a7d18aad6536c23
Parent:        6db5b91231ce7ac84fafd4190bb3b4a079db1f49
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 8 16:20:51 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 11 16:58:20 2016 +0100

cleanup: debug trace and indent change

---
 lib/activate/dev_manager.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index da66374..1a79c08 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2305,7 +2305,7 @@ static char *_add_error_or_zero_device(struct dev_manager *dm, struct dm_tree *d
 		if (!dm_tree_add_dev(dtree, info.major, info.minor)) {
 			log_error("Failed to add device (%" PRIu32 ":%" PRIu32") to dtree.",
 				  info.major, info.minor);
-			return_NULL;
+			return NULL;
 		}
 	}
 
@@ -2833,7 +2833,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
-        /* Even unused thin-pool still needs to get layered  UUID -suffix */
+	/* Even unused thin-pool still needs to get layered  UUID -suffix */
 	if (!layer && lv_is_new_thin_pool(lv))
 		layer = lv_layer(lv);
 


