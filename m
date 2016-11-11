From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Nov 2016 16:00:10 +0000 (UTC)
Subject: master - cleanup: add dots to debug messages
Message-ID: <20161111160010.EE57A601A6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1bdcb01f63f849950f381a0a33a046f01f3d6f2a
Commit:        1bdcb01f63f849950f381a0a33a046f01f3d6f2a
Parent:        b38564b8dc8a1e26f1937158dc7fc2d7c0b0804c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 11 16:38:04 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 11 16:58:20 2016 +0100

cleanup: add dots to debug messages

---
 lib/activate/dev_manager.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index dcea359..da66374 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2283,7 +2283,7 @@ static char *_add_error_or_zero_device(struct dev_manager *dm, struct dm_tree *d
 				      seg->lv->name, errid)))
 		return_NULL;
 
-	log_debug_activation("Getting device info for %s [%s]", name, dlid);
+	log_debug_activation("Getting device info for %s [%s].", name, dlid);
 	if (!_info(dm->cmd, dlid, 1, 0, &info, NULL, NULL)) {
 		log_error("Failed to get info for %s [%s].", name, dlid);
 		return 0;
@@ -2303,7 +2303,7 @@ static char *_add_error_or_zero_device(struct dev_manager *dm, struct dm_tree *d
 	} else {
 		/* Already exists */
 		if (!dm_tree_add_dev(dtree, info.major, info.minor)) {
-			log_error("Failed to add device (%" PRIu32 ":%" PRIu32") to dtree",
+			log_error("Failed to add device (%" PRIu32 ":%" PRIu32") to dtree.",
 				  info.major, info.minor);
 			return_NULL;
 		}


