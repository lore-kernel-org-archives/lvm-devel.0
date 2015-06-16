From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 16 Jun 2015 19:24:47 +0000 (UTC)
Subject: master - Add the 's' activation mode
Message-ID: <20150616192447.E3A1560DB6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d5adec105626c39ffd6295c832dfda9189a1d85d
Commit:        d5adec105626c39ffd6295c832dfda9189a1d85d
Parent:        1f318dbcee07a309a2b2e8f391897a744e68c477
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 16 10:18:16 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 16 10:18:16 2015 -0500

Add the 's' activation mode

Just as 'e' means activation with an exclusive lock,
add an 's' to mean activation with a shared lock.

This allows the existing but implicit behavior of '-ay'
of clvm LVs to be specified explicitly.  For local VGs,
asy simply means ay, just like aey means ay.

For local VGs, ay == aey == asy

For clvm VGs,  ay == asy, aey == aey, asy == asy
---
 lib/metadata/lv.c                |    4 +++-
 lib/metadata/metadata-exported.h |    3 ++-
 tools/lvmcmdline.c               |    6 ++++++
 3 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 10ce906..9a99c8d 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -953,7 +953,9 @@ exclusive:
 		if (!activate_lv_excl(cmd, lv))
 			return_0;
 		break;
-	default: /* CHANGE_AY */
+	case CHANGE_ASY:
+	case CHANGE_AY:
+	default:
 		if (needs_exclusive || _lv_is_exclusive(lv))
 			goto exclusive;
 		log_verbose("Activating logical volume \"%s\".", lv->name);
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0e52153..b673af3 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -828,7 +828,8 @@ typedef enum activation_change {
 	CHANGE_AEY = 2, /* activate exclusively */
 	CHANGE_ALY = 3, /* activate locally */
 	CHANGE_ALN = 4, /* deactivate locally */
-	CHANGE_AAY = 5  /* automatic activation */
+	CHANGE_AAY = 5, /* automatic activation */
+	CHANGE_ASY = 6  /* activate shared */
 } activation_change_t;
 
 /* Returns true, when change activates device */
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 29fffb3..792dc41 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -286,6 +286,12 @@ int activation_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_v
 		av->ui_value = CHANGE_AEY;
 	}
 
+	else if (!strcmp(av->value, "s") || !strcmp(av->value, "sy") ||
+		 !strcmp(av->value, "ys")) {
+		av->i_value = CHANGE_ASY;
+		av->ui_value = CHANGE_ASY;
+	}
+
 	else if (!strcmp(av->value, "y")) {
 		av->i_value = CHANGE_AY;
 		av->ui_value = CHANGE_AY;


