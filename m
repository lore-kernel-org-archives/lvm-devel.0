From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  1 Apr 2014 18:56:05 +0000 (UTC)
Subject: master - cleanup: cache reuse code for pool test
Message-ID: <20140401185605.588426092A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d58cc2c0fc7cd8fd658b03d6fabdfbdf757562c8
Commit:        d58cc2c0fc7cd8fd658b03d6fabdfbdf757562c8
Parent:        e72dea55bf3ba3b03014b2f04edeb048ade296eb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 1 20:06:54 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 1 20:18:05 2014 +0200

cleanup: cache reuse code for pool test

Using same error message for pool associated devices.
---
 lib/metadata/lv_manip.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2da6ae1..5d2cdb9 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4681,19 +4681,14 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
-	if (lv_is_thin_pool_data(lv) || lv_is_thin_pool_metadata(lv)) {
-		log_error("Can't remove logical volume %s used by a thin pool.",
+	if (lv_is_thin_pool_data(lv) || lv_is_thin_pool_metadata(lv) ||
+	    lv_is_cache_pool_data(lv) || lv_is_cache_pool_metadata(lv)) {
+		log_error("Can't remove logical volume %s used by a pool.",
 			  lv->name);
 		return 0;
 	} else if (lv_is_thin_volume(lv))
 		pool_lv = first_seg(lv)->pool_lv;
 
-	if (lv_is_cache_pool_data(lv) || lv_is_cache_pool_metadata(lv)) {
-		log_error("Can't remove logical volume %s used by a cache_pool.",
-			  lv->name);
-		return 0;
-	}
-
 	if (lv->status & LOCKED) {
 		log_error("Can't remove locked LV %s", lv->name);
 		return 0;


