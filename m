From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 10 Dec 2015 20:07:08 +0000 (UTC)
Subject: master - lvrename: always allow to rename pools
Message-ID: <20151210200708.CBDFC610E4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cd8e95d9337207a8f87a6f68dc9b1db7e3828bbf
Commit:        cd8e95d9337207a8f87a6f68dc9b1db7e3828bbf
Parent:        bf4b74c5eb55cdb77c8a7e7e697fb2d43b39c718
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 9 13:52:47 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 10 21:01:24 2015 +0100

lvrename: always allow to rename pools

Since we mark cache-pool as 'hidden/private' while it is in-use,
we may still allow user to change it's name.

It should not cause any harm and user may prefer better naming
for a cache-pool in use.
---
 lib/metadata/lv_manip.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6a93a76..76e7895 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4230,8 +4230,12 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 	struct volume_group *vg = lv->vg;
 	struct lv_names lv_names = { .old = lv->name };
 
-	/* rename is not allowed on sub LVs */
-	if (!lv_is_visible(lv)) {
+	/*
+	 * rename is not allowed on sub LVs except for pools
+	 * (thin pool is 'visible', but cache may not)
+	 */
+	if (!lv_is_pool(lv) &&
+	    !lv_is_visible(lv)) {
 		log_error("Cannot rename internal LV \"%s\".", lv->name);
 		return 0;
 	}
@@ -4265,7 +4269,7 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 	if (lv_is_cow(lv))
 		lv = origin_from_cow(lv);
 
-	if (update_mda && !lv_update_and_reload(lv))
+	if (update_mda && !lv_update_and_reload((struct logical_volume *)lv_lock_holder(lv)))
 		return_0;
 
 	return 1;


