From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 26 Jun 2013 14:55:27 +0000 (UTC)
Subject: dev-peter-config-profiles - cleanup: move mirror check code closer
Message-ID: <20130626145527.603CD60E54@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=19b064a30939df25ef1f31337ac6b566023b7793
Commit:        19b064a30939df25ef1f31337ac6b566023b7793
Parent:        09dc590b67518b3e90944aea981be196dd9387a0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 24 11:55:18 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 25 13:47:39 2013 +0200

cleanup: move mirror check code closer

Group a bit more code related to mirrors.
---
 tools/lvcreate.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index e9e00be..43bb3d6 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -771,7 +771,19 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		lp->mirrors = 2;
 
 	if (arg_count(cmd, mirrors_ARG)) {
+		if (arg_sign_value(cmd, mirrors_ARG, SIGN_NONE) == SIGN_MINUS) {
+			log_error("Mirrors argument may not be negative");
+			return 0;
+		}
+
 		lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0) + 1;
+
+		if (lp->mirrors > DEFAULT_MIRROR_MAX_IMAGES) {
+			log_error("Only up to " DM_TO_STRING(DEFAULT_MIRROR_MAX_IMAGES)
+				  " images in mirror supported currently.");
+			return 0;
+		}
+
 		if (lp->mirrors == 1) {
 			if (segtype_is_mirrored(lp->segtype)) {
 				log_error("--mirrors must be at least 1 with segment type %s.", lp->segtype->name);
@@ -790,11 +802,6 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 				  "only 2-way mirroring (i.e. '-m 1')");
 			return 0;
 		}
-
-		if (arg_sign_value(cmd, mirrors_ARG, SIGN_NONE) == SIGN_MINUS) {
-			log_error("Mirrors argument may not be negative");
-			return 0;
-		}
 	}
 
 	if (lp->snapshot && arg_count(cmd, zero_ARG)) {
@@ -880,12 +887,6 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		return 0;
 	}
 
-	if (lp->mirrors > DEFAULT_MIRROR_MAX_IMAGES) {
-		log_error("Only up to " DM_TO_STRING(DEFAULT_MIRROR_MAX_IMAGES)
-			  " images in mirror supported currently.");
-		return 0;
-	}
-
 	/*
 	 * Allocation parameters
 	 */


