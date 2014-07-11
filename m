From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 11:34:39 +0000 (UTC)
Subject: master - cleanup: shift detection of chunksize sign
Message-ID: <20140711113439.42E8D6056E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fe3ea94e5846f48baf3b00d0f6b913f585b4404e
Commit:        fe3ea94e5846f48baf3b00d0f6b913f585b4404e
Parent:        9955204e0d9d8d50c19564d475ece03995a6e837
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 7 22:40:36 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 13:32:22 2014 +0200

cleanup: shift detection of chunksize sign

Sign should be checked prior opening of VG.
Since get_pool_params() needs profiles,
we need to move check for sign earlier.
---
 tools/lvconvert.c |   15 +++++++++++----
 tools/lvcreate.c  |   12 +++++++-----
 tools/toollib.c   |    4 ----
 3 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 95ca245..8c960f9 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -447,10 +447,12 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			return 0;
 		}
 
-		if (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS) {
-			log_error("Negative chunk size is invalid");
+		if (arg_count(cmd, chunksize_ARG) &&
+		    (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS)) {
+			log_error("Negative chunk size is invalid.");
 			return 0;
 		}
+
 		lp->chunk_size = arg_uint_value(cmd, chunksize_ARG, 8);
 		if (lp->chunk_size < 8 || lp->chunk_size > 1024 ||
 		    (lp->chunk_size & (lp->chunk_size - 1))) {
@@ -540,10 +542,15 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 		lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, cache_pool ? "cache-pool" : "thin-pool"));
 		if (!lp->segtype)
 			return_0;
+
+		if (arg_count(cmd, chunksize_ARG) &&
+		    (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS)) {
+			log_error("Negative chunk size is invalid.");
+			return 0;
+		}
 	} else { /* Mirrors (and some RAID functions) */
 		if (arg_count(cmd, chunksize_ARG)) {
-			log_error("--chunksize is only available with "
-				  "snapshots or thin pools.");
+			log_error("--chunksize is only available with snapshots or pools.");
 			return 0;
 		}
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 47459ec..8e45cc1 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1033,6 +1033,12 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 			lp->wipe_signatures = 0;
 	}
 
+	if (arg_count(cmd, chunksize_ARG) &&
+	    (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS)) {
+		log_error("Negative chunk size is invalid.");
+		return 0;
+	}
+
 	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
 	    !_read_size_params(lp, lcp, cmd) ||
 	    !get_stripe_params(cmd, &lp->stripes, &lp->stripe_size) ||
@@ -1047,10 +1053,6 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		return_0;
 
 	if (lp->snapshot && (lp->extents || lcp->size)) {
-		if (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS) {
-			log_error("Negative chunk size is invalid.");
-			return 0;
-		}
 		lp->chunk_size = arg_uint_value(cmd, chunksize_ARG, 8);
 		if (lp->chunk_size < 8 || lp->chunk_size > 1024 ||
 		    (lp->chunk_size & (lp->chunk_size - 1))) {
@@ -1063,7 +1065,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		if (!(lp->segtype = get_segtype_from_string(cmd, "snapshot")))
 			return_0;
 	} else if (!lp->create_pool && arg_count(cmd, chunksize_ARG)) {
-		log_error("--chunksize is only available with snapshots and thin pools.");
+		log_error("--chunksize is only available with snapshots and pools.");
 		return 0;
 	}
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 7cd6e60..b4e02d6 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1688,10 +1688,6 @@ int get_pool_params(struct cmd_context *cmd,
 	}
 
 	if (arg_count(cmd, chunksize_ARG)) {
-		if (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS) {
-			log_error("Negative chunk size is invalid.");
-			return 0;
-		}
 		*passed_args |= PASS_ARG_CHUNK_SIZE;
 		*chunk_size = arg_uint_value(cmd, chunksize_ARG, cache_pool ?
 					     DM_CACHE_MIN_DATA_BLOCK_SIZE :


