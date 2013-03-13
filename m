From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 Mar 2013 14:16:11 +0000 (UTC)
Subject: master - thin: read paramaters in front
Message-ID: <20130313141611.B2908A0D6D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f572bf987e15429392b5ed4d2f0f01d53a95563b
Commit:        f572bf987e15429392b5ed4d2f0f01d53a95563b
Parent:        82eee72019e7311341fcd4e36bf92a8264f353cd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 11 12:40:05 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 13 15:13:54 2013 +0100

thin: read paramaters in front

Fill paramaters into lvconvert_params -
so we could use it independently on args()
---
 tools/lvconvert.c |   21 +++++++++++++++------
 1 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 932a4f6..1ab9971 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -18,9 +18,12 @@
 #include "metadata.h"
 
 struct lvconvert_params {
+	int force;
 	int snapshot;
 	int merge;
 	int merge_mirror;
+	int thin;
+	int yes;
 	int zero;
 
 	const char *origin;
@@ -97,12 +100,12 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 
 	if (lp->pool_data_lv_name) {
 		if (*pargc) {
-			if (!arg_count(cmd, thin_ARG)) {
+			if (!lp->thin) {
 				log_error("More then one logical volume name specified.");
 				return 0;
 			}
 		} else {
-			if (arg_count(cmd, thin_ARG)) {
+			if (lp->thin) {
 				log_error("External thin volume name is missing.");
 				return 0;
 			}
@@ -219,6 +222,9 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (arg_count(cmd, thin_ARG))
+		lp->thin = 1;
+
 	if (arg_count(cmd, thinpool_ARG)) {
 		if (arg_count(cmd, merge_ARG)) {
 			log_error("--thinpool and --merge are mutually exlusive.");
@@ -241,7 +247,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			return 0;
 		}
 		lp->discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_PASSDOWN);
-	} else if (arg_count(cmd, thin_ARG)) {
+	} else if (lp->thin) {
 		log_error("--thin is only valid with --thinpool.");
 		return 0;
 	} else if (arg_count(cmd, discards_ARG)) {
@@ -488,6 +494,9 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			return_0;
 	}
 
+	lp->force = arg_count(cmd, force_ARG);
+	lp->yes = arg_count(cmd, yes_ARG);
+
 	if (activation() && lp->segtype && lp->segtype->ops->target_present &&
 	    !lp->segtype->ops->target_present(cmd, NULL, &lp->target_attr)) {
 		log_error("%s: Required device-mapper target(s) not "
@@ -2001,7 +2010,7 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (arg_count(cmd, thin_ARG)) {
+	if (lp->thin) {
 		external_lv = pool_lv;
 		if (!(pool_lv = find_lv(external_lv->vg, lp->pool_data_lv_name))) {
 			log_error("Can't find pool LV %s/%s.",
@@ -2072,7 +2081,7 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 				log_error("Aborting. Failed to deactivate thin metadata lv.");
 				return 0;
 			}
-			if (!arg_count(cmd, yes_ARG) &&
+			if (!lp->yes &&
 			    yes_no_prompt("Do you want to swap metadata of %s/%s pool with "
 					  "volume %s/%s? [y/n]: ",
 					  pool_lv->vg->name, pool_lv->name,
@@ -2093,7 +2102,7 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 			if (!arg_count(cmd, chunksize_ARG))
 				lp->chunk_size = seg->chunk_size;
 			else if ((lp->chunk_size != seg->chunk_size) &&
-				 !arg_count(cmd, force_ARG) &&
+				 !lp->force &&
 				 yes_no_prompt("Do you really want to change chunk size %s to %s for %s/%s "
 					       "pool volume? [y/n]: ", display_size(cmd, seg->chunk_size),
 					       display_size(cmd, lp->chunk_size),


