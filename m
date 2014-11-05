From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  5 Nov 2014 14:33:29 +0000 (UTC)
Subject: master - lv: lv_active_change add needs_exclusive flag
Message-ID: <20141105143329.ACCBB60E61@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a3a2c792a87054ab78a1b8e54b99db1c24739fb8
Commit:        a3a2c792a87054ab78a1b8e54b99db1c24739fb8
Parent:        a82dcadf66dbd43a43d3be40cd62a5074248d218
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 5 15:14:58 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 5 15:29:43 2014 +0100

lv: lv_active_change add needs_exclusive flag

Let's use this function for more activations in the code.

'needs_exlusive' will enforce exlusive type for any given LV.

We may want to activate LV in exlusive mode, even when we know
the LV (as is) supports non-exlusive activation as well.

lvcreate -ay   -> exclusive & local
lvcreate -aay  -> exclusive & local
lvcreate -aly  -> exclusive & local
lvcreate -aey  -> exclusive  (might be on any node).
---
 lib/metadata/lv.c       |    8 ++++----
 lib/metadata/lv.h       |    2 +-
 lib/metadata/lv_manip.c |    4 ++--
 tools/lvchange.c        |    2 +-
 tools/toollib.c         |    2 +-
 5 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 92b38f4..ed21894 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -866,7 +866,7 @@ static int _lv_is_exclusive(struct logical_volume *lv)
 }
 
 int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
-		     enum activation_change activate)
+		     enum activation_change activate, int needs_exclusive)
 {
 	switch (activate) {
 	case CHANGE_AN:
@@ -876,7 +876,7 @@ deactivate:
 			return_0;
 		break;
 	case CHANGE_ALN:
-		if (vg_is_clustered(lv->vg) && _lv_is_exclusive(lv)) {
+		if (vg_is_clustered(lv->vg) && (needs_exclusive || _lv_is_exclusive(lv))) {
 			if (!lv_is_active_locally(lv)) {
 				log_error("Cannot deactivate remotely exclusive device locally.");
 				return 0;
@@ -891,7 +891,7 @@ deactivate:
 		break;
 	case CHANGE_ALY:
 	case CHANGE_AAY:
-		if (_lv_is_exclusive(lv)) {
+		if (needs_exclusive || _lv_is_exclusive(lv)) {
 			log_verbose("Activating logical volume \"%s\" exclusively locally.",
 				    lv->name);
 			if (!activate_lv_excl_local(cmd, lv))
@@ -911,7 +911,7 @@ exclusive:
 			return_0;
 		break;
 	default: /* CHANGE_AY */
-		if (_lv_is_exclusive(lv))
+		if (needs_exclusive || _lv_is_exclusive(lv))
 			goto exclusive;
 		log_verbose("Activating logical volume \"%s\".", lv->name);
 		if (!activate_lv(cmd, lv))
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 2261913..8064ba2 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -94,7 +94,7 @@ int lv_set_creation(struct logical_volume *lv,
 		    const char *hostname, uint64_t timestamp);
 const char *lv_layer(const struct logical_volume *lv);
 int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
-		     enum activation_change activate);
+		     enum activation_change activate, int needs_exlusive);
 char *lv_active_dup(struct dm_pool *mem, const struct logical_volume *lv);
 const struct logical_volume *lv_lock_holder(const struct logical_volume *lv);
 const struct logical_volume *lv_ondisk(const struct logical_volume *lv);
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6cf51f9..30188e4 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7051,7 +7051,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 			backup(vg);
 
-			if (!lv_active_change(cmd, lv, lp->activate)) {
+			if (!lv_active_change(cmd, lv, lp->activate, 0)) {
 				log_error("Failed to activate thin %s.", lv->name);
 				goto deactivate_and_revert_new_lv;
 			}
@@ -7070,7 +7070,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				  "exception store.");
 			goto revert_new_lv;
 		}
-	} else if (!lv_active_change(cmd, lv, lp->activate)) {
+	} else if (!lv_active_change(cmd, lv, lp->activate, 0)) {
 		log_error("Failed to activate new LV.");
 		goto deactivate_and_revert_new_lv;
 	}
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 99dba82..e0bb4b1 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -593,7 +593,7 @@ static int lvchange_persistent(struct cmd_context *cmd,
 
 	if (activate != CHANGE_AN) {
 		log_verbose("Re-activating logical volume %s", display_lvname(lv));
-		if (!lv_active_change(cmd, lv, activate)) {
+		if (!lv_active_change(cmd, lv, activate, 0)) {
 			log_error("%s: reactivation failed", display_lvname(lv));
 			backup(lv->vg);
 			return 0;
diff --git a/tools/toollib.c b/tools/toollib.c
index 5906ccb..596dba5 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -731,7 +731,7 @@ int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
-	if (!lv_active_change(cmd, lv, activate))
+	if (!lv_active_change(cmd, lv, activate, 0))
 		return_0;
 
 	if (background_polling() &&


