From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun,  2 Dec 2012 17:02:26 +0000 (UTC)
Subject: master - thin: lvconvert update messages
Message-ID: <20121202170226.D5857A0D87@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0be8a9126f9e6e66bce186192fedbb5d841007f2
Commit:        0be8a9126f9e6e66bce186192fedbb5d841007f2
Parent:        6987a353de9476c57831fdcf9cccb5d80e4f505b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 2 16:23:44 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 2 17:56:44 2012 +0100

thin: lvconvert update messages

---
 tools/lvconvert.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index e428ce0..76588d2 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1813,7 +1813,7 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 
 	/* We are changing target type, so deactivate first */
 	if (!deactivate_lv(cmd, pool_lv)) {
-		log_error("Can't deactivate logical volume %s/%s.",
+		log_error("Aborting. Failed to deactivate logical volume %s/%s.",
 			  pool_lv->vg->name, pool_lv->name);
 		return 0;
 	}
@@ -1824,8 +1824,10 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (dm_snprintf(name, len, "%s_tmeta", pool_lv->name) < 0)
-		return_0;
+	if (dm_snprintf(name, len, "%s_tmeta", pool_lv->name) < 0) {
+		log_error("Failed to create layer name.");
+		return 0;
+	}
 
 	if (lp->pool_metadata_lv_name) {
 		if (arg_count(cmd, stripesize_ARG) || arg_count(cmd, stripes_long_ARG)) {
@@ -1864,8 +1866,8 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		}
 		if (!lv_is_active(metadata_lv) &&
 		    !activate_lv_local(cmd, metadata_lv)) {
-		    log_error("Aborting. Failed to activate thin metadata lv.");
-		    return 0;
+			log_error("Aborting. Failed to activate thin metadata lv.");
+			return 0;
 		}
 		if (!set_lv(cmd, metadata_lv, UINT64_C(0), 0)) {
 			log_error("Aborting. Failed to wipe thin metadata lv.");


