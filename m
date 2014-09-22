From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:39:21 +0000 (UTC)
Subject: dev-dct-process-latest - wipe_lv: move sync_local_dev_names in front
Message-ID: <20140922153921.8E5E86092E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f1e9e94a5b2d4aa6b7c454634c2b45b2a1082822
Commit:        f1e9e94a5b2d4aa6b7c454634c2b45b2a1082822
Parent:        d8b775f4eb871e771c9f18dcd9f6b28509e7e52a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 19 11:06:31 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 19 15:51:30 2014 +0200

wipe_lv: move sync_local_dev_names in front

Synchronize things before checking for locally active volume.
---
 lib/metadata/lv_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2e683b9..968b8d0 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6360,6 +6360,8 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 		/* nothing to do */
 		return 1;
 
+	sync_local_dev_names(lv->vg->cmd);  /* Wait until devices are available */
+
 	if (!lv_is_active_locally(lv)) {
 		log_error("Volume \"%s/%s\" is not active locally.",
 			  lv->vg->name, lv->name);
@@ -6379,8 +6381,6 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 		return 0;
 	}
 
-	sync_local_dev_names(lv->vg->cmd);  /* Wait until devices are available */
-
 	if (!(dev = dev_cache_get(name, NULL))) {
 		log_error("%s: not found: device not cleared", name);
 		return 0;


