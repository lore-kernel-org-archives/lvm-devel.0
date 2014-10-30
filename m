From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Oct 2014 23:00:36 +0000 (UTC)
Subject: master - lvcreate: improving recent lvcreate updates
Message-ID: <20141030230036.E377460654@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=87fc3b710c3b8fc656dcf48ec453e1da280ec696
Commit:        87fc3b710c3b8fc656dcf48ec453e1da280ec696
Parent:        651613e9a40c9cc0aaf4a1c7c262ad394ac93ffb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 30 23:36:07 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 30 23:58:48 2014 +0100

lvcreate: improving recent lvcreate updates

We need to be able to parse:

lvcreate --type snapshot -s
lvcreate --type thin -s
lvcreate --type cache-pool -H
---
 tools/lvcreate.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index e507858..6b8c4b5 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -153,6 +153,8 @@ static int _lvcreate_name_params(struct cmd_context *cmd,
 
 		vg_name = skip_dev_dir(cmd, argv[0], NULL);
 		if (!strchr(vg_name, '/')) {
+			if (lp->snapshot && arg_is_set(cmd, virtualsize_ARG))
+				lp->snapshot = 0 ; /* Sparse volume via thin-pool */
 			if (!_set_vg_name(lp, vg_name))
 				return_0;
 		} else {
@@ -639,10 +641,6 @@ static int _lvcreate_params(struct cmd_context *cmd,
 			segtype_str = "striped";
 			only_linear = 1; /* User requested linear only target */
 		}
-		if (arg_from_list_is_set(cmd, "is conflicting with option --type",
-					 cache_ARG, thin_ARG, snapshot_ARG,
-					 -1))
-			return_0;
 	/* More estimations from options after shortcuts */
 	} else if (arg_is_set(cmd, snapshot_ARG) &&
 		   (arg_is_set(cmd, virtualoriginsize_ARG) ||
@@ -754,6 +752,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 					    LVCREATE_ARGS,
 					    POOL_ARGS,
 					    SIZE_ARGS,
+					    cache_ARG,
 					    chunksize_ARG,
 					    -1))
 			return_0;
@@ -853,6 +852,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 					    SIZE_ARGS,
 					    THIN_POOL_ARGS,
 					    chunksize_ARG,
+					    snapshot_ARG,
 					    thin_ARG,
 					    virtualsize_ARG,
 					    wipesignatures_ARG, zero_ARG,
@@ -888,7 +888,8 @@ static int _lvcreate_params(struct cmd_context *cmd,
 					return_0;
 			} else	/* Parse free arg as snapshot origin */
 				lp->snapshot = 1;
-		}
+		} else if (arg_is_set(cmd, snapshot_ARG))
+			lp->snapshot = 1;
 	} else if (seg_is_thin_pool(lp)) {
 		if (arg_outside_list_is_set(cmd, "is unsupported with thin pools",
 					    LVCREATE_ARGS,


