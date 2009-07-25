From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 24 Jul 2009 20:08:10 -0400
Subject: [PATCH 01/11] Refactor _lvcreate - move *_ARG into _lvcreate_params and get 'cmd' from 'vg'.
In-Reply-To: <1248480500-472-1-git-send-email-dwysocha@redhat.com>
References: <1248480500-472-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1248480500-472-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

A couple simple refactorings of _lvcreate - should be no functional change.
Move tags_ARG parsing into _lvcreate_params.  Also use lp->voriginsize
instread of arg_count().  These refactorings make it easier to move the
bulk of _lvcreate into the library.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/lvcreate.c |   26 ++++++++++++++------------
 1 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 165bf7c..af18ca8 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -53,6 +53,7 @@ struct lvcreate_params {
 
 	int pv_count;
 	char **pvs;
+	const char *tag;
 };
 
 static int _lvcreate_name_params(struct lvcreate_params *lp,
@@ -525,6 +526,12 @@ static int _lvcreate_params(struct lvcreate_params *lp, struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (arg_count(cmd, addtag_ARG) &&
+	    !(lp->tag = arg_str_value(cmd, addtag_ARG, NULL))) {
+		log_error("Failed to get tag");
+		return 0;
+	}
+
 	lp->pv_count = argc;
 	lp->pvs = argv;
 
@@ -593,14 +600,14 @@ static struct logical_volume *_create_virtual_origin(struct cmd_context *cmd,
 	return lv;
 }
 
-static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
+static int _lvcreate(struct volume_group *vg,
 		     struct lvcreate_params *lp)
 {
+	struct cmd_context *cmd = vg->cmd;
 	uint32_t size_rest;
 	uint32_t status = 0;
 	struct logical_volume *lv, *org = NULL;
 	struct dm_list *pvh;
-	const char *tag = NULL;
 	int origin_active = 0;
 	char lv_name_buf[128];
 	const char *lv_name;
@@ -722,7 +729,7 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 		/* Must zero cow */
 		status |= LVM_WRITE;
 
-		if (arg_count(cmd, virtualsize_ARG))
+		if (lp->voriginsize)
 			origin_active = 1;
 		else {
 
@@ -806,12 +813,7 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 		lv_name = &lv_name_buf[0];
 	}
 
-	if (arg_count(cmd, addtag_ARG)) {
-		if (!(tag = arg_str_value(cmd, addtag_ARG, NULL))) {
-			log_error("Failed to get tag");
-			return 0;
-		}
-
+	if (lp->tag) {
 		if (!(vg->fid->fmt->features & FMT_TAGS)) {
 			log_error("Volume group %s does not support tags",
 				  vg->name);
@@ -846,9 +848,9 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 			    lv->minor);
 	}
 
-	if (tag && !str_list_add(cmd->mem, &lv->tags, tag)) {
+	if (lp->tag && !str_list_add(cmd->mem, &lv->tags, lp->tag)) {
 		log_error("Failed to add tag %s to %s/%s",
-			  tag, lv->vg->name, lv->name);
+			  lp->tag, lv->vg->name, lv->name);
 		return 0;
 	}
 
@@ -1000,7 +1002,7 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	if (!_lvcreate(cmd, vg, &lp))
+	if (!_lvcreate(vg, &lp))
 		r = ECMD_FAILED;
 
 	unlock_and_release_vg(cmd, vg, lp.vg_name);
-- 
1.6.0.6


