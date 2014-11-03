From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:23:23 +0000 (UTC)
Subject: master - lvcreate: tollerate defaults
Message-ID: <20141103132323.E6B8B602D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c1ee6d4ffc7d520e015a8e44f50392510fb85167
Commit:        c1ee6d4ffc7d520e015a8e44f50392510fb85167
Parent:        ed2a0560ad23f3de0b63e4c48ce91e6d5c744c23
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 31 13:37:39 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:32 2014 +0100

lvcreate: tollerate defaults

lvcreate -m0 and -Mn goes with anything.
Read ahead works either with pools or thin/cache, but not with both.
---
 tools/lvcreate.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 6b8c4b5..b6768ba 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -653,7 +653,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 		segtype_str = "thin";
 	else if (arg_is_set(cmd, virtualsize_ARG)) {
 		if (arg_is_set(cmd, virtualoriginsize_ARG))
-			segtype_str = "snapshot";
+			segtype_str = "snapshot"; /* --virtualoriginsize incompatible with pools */
 		else
 			segtype_str = find_config_tree_str(cmd, global_sparse_segtype_default_CFG, NULL);
 	} else if (arg_uint_value(cmd, mirrors_ARG, 0)) {
@@ -685,9 +685,12 @@ static int _lvcreate_params(struct cmd_context *cmd,
 	contiguous_ARG,\
 	ignoreactivationskip_ARG,\
 	ignoremonitoring_ARG,\
+	mirrors_ARG,\
 	name_ARG,\
 	noudevsync_ARG,\
 	permission_ARG,\
+	persistent_ARG,\
+	readahead_ARG,\
 	setactivationskip_ARG,\
 	test_ARG,\
 	type_ARG
@@ -701,14 +704,12 @@ static int _lvcreate_params(struct cmd_context *cmd,
 	mirrorlog_ARG
 
 #define MIRROR_RAID_ARGS \
-	mirrors_ARG,\
 	nosync_ARG,\
 	regionsize_ARG
 
 #define PERSISTENT_ARGS \
 	major_ARG,\
-	minor_ARG,\
-	persistent_ARG
+	minor_ARG
 
 #define POOL_ARGS \
 	pooldatasize_ARG,\
@@ -1210,13 +1211,6 @@ static int _check_thin_parameters(struct volume_group *vg, struct lvcreate_param
 	}
 
 	if (!seg_is_thin_volume(lp) && !lp->snapshot) {
-		/* Not creating thin volume nor snapshot */
-		if (arg_from_list_is_set(vg->cmd, "may only be given when creating a new thin Logical volume or snapshot",
-					 permission_ARG,
-					 persistent_ARG,
-					 readahead_ARG,
-					 -1))
-			return_0;
 		if (!lp->create_pool) {
 			/* Not even creating thin pool? */
 			log_error("Please specify device size(s).");
@@ -1285,7 +1279,14 @@ static int _check_pool_parameters(struct cmd_context *cmd,
 			}
 			/* When creating just pool the pool_name needs to be in lv_name */
 			lp->lv_name = lp->pool_name;
+		} else if (vg) {
+			/* FIXME: what better to do with --readahead and pools? */
+			if (arg_is_set(cmd, readahead_ARG)) {
+				log_error("Ambigous --readahead parameter specified. Please use either with pool or volume.");
+				return 0;
+			}
 		}
+
 		return 1;
 	}
 	/* Not creating new pool, but existing pool is needed */


