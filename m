From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 20 Apr 2018 07:02:16 -0400
Subject: master - cleanup: reorder condition
Message-ID: <201804201102.w3KB2G2g031301@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=27a1a0e5c04806e217dbd9c197dc95c05341ed54
Commit:        27a1a0e5c04806e217dbd9c197dc95c05341ed54
Parent:        1287edf6264b910a1f0d6dfbd809c2b51fe3ff2a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 29 22:53:13 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 20 12:17:01 2018 +0200

cleanup: reorder condition

There is no point to wait for sync for non-locally active LV.
---
 lib/metadata/lv_manip.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e377cf8..97a4e39 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7149,6 +7149,12 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 		/* nothing to do */
 		return 1;
 
+	if (!lv_is_active_locally(lv)) {
+		log_error("Volume \"%s/%s\" is not active locally (volume_list activation filter?).",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
 	/* Wait until devices are available */
 	if (!sync_local_dev_names(lv->vg->cmd)) {
 		log_error("Failed to sync local devices before wiping LV %s.",
@@ -7156,12 +7162,6 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 		return 0;
 	}
 
-	if (!lv_is_active_locally(lv)) {
-		log_error("Volume \"%s/%s\" is not active locally (volume_list activation filter?).",
-			  lv->vg->name, lv->name);
-		return 0;
-	}
-
 	/*
 	 * FIXME:
 	 * <clausen> also, more than 4k


