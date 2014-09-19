From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 19 Sep 2014 13:57:32 +0000 (UTC)
Subject: master - cleanup: switch to use CHANGE_AEY
Message-ID: <20140919135732.36A8E60398@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e2312d28ed031dd5c53084b4789763f3c5e6410c
Commit:        e2312d28ed031dd5c53084b4789763f3c5e6410c
Parent:        f1e9e94a5b2d4aa6b7c454634c2b45b2a1082822
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 19 14:28:28 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 19 15:51:31 2014 +0200

cleanup: switch to use CHANGE_AEY

Since for other enums we use 'Y' or 'N' use it with 'AE' as well.
---
 lib/metadata/lv.c                |    2 +-
 lib/metadata/metadata-exported.h |    2 +-
 tools/lvconvert.c                |    2 +-
 tools/lvmcmdline.c               |    4 ++--
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 3ebb14d..d29e787 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -888,7 +888,7 @@ deactivate:
 				return_0;
 		}
 		break;
-	case CHANGE_AE:
+	case CHANGE_AEY:
 exclusive:
 		log_verbose("Activating logical volume \"%s\" exclusively.",
 			    lv->name);
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 9dac46a..935d3f7 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -776,7 +776,7 @@ int is_mirror_image_removable(struct logical_volume *mimage_lv, void *baton);
 typedef enum activation_change {
 	CHANGE_AY = 0,  /* activate */
 	CHANGE_AN = 1,  /* deactivate */
-	CHANGE_AE = 2,  /* activate exclusively */
+	CHANGE_AEY = 2,  /* activate exclusively */
 	CHANGE_ALY = 3, /* activate locally */
 	CHANGE_ALN = 4, /* deactivate locally */
 	CHANGE_AAY = 5  /* automatic activation */
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 2cd5ba6..6a2676b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2513,7 +2513,7 @@ static int _lvconvert_thin(struct cmd_context *cmd,
 	struct logical_volume *torigin_lv, *pool_lv = lp->pool_data_lv;
 	struct volume_group *vg = pool_lv->vg;
 	struct lvcreate_params lvc = {
-		.activate = CHANGE_AE,
+		.activate = CHANGE_AEY,
 		.alloc = ALLOC_INHERIT,
 		.lv_name = lp->origin_lv_name,
 		.major = -1,
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 14ea7a6..04598e2 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -242,8 +242,8 @@ int activation_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_v
 
 	if (!strcmp(av->value, "e") || !strcmp(av->value, "ey") ||
 	    !strcmp(av->value, "ye")) {
-		av->i_value = CHANGE_AE;
-		av->ui_value = CHANGE_AE;
+		av->i_value = CHANGE_AEY;
+		av->ui_value = CHANGE_AEY;
 	}
 
 	else if (!strcmp(av->value, "y")) {


