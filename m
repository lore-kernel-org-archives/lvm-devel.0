From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 17 Jul 2014 14:29:23 +0000 (UTC)
Subject: master - cleanup: drop testing impossible path
Message-ID: <20140717142923.E4DED60DBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=53b787e519261008c4b1d96ea58243c9e2e06f25
Commit:        53b787e519261008c4b1d96ea58243c9e2e06f25
Parent:        ffa1a7b046b0ec62d478a848181f16c4ee0126bb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 17 14:47:58 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 17 16:20:21 2014 +0200

cleanup: drop testing impossible path

We cannot get NULL in this test - since if the arg is set
it will always return non-NULL value here.
(in-release update)
---
 tools/lvconvert.c |   18 +++---------------
 1 files changed, 3 insertions(+), 15 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index b630ee2..63a1d98 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -242,10 +242,7 @@ static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cm
 				  " the cache or cache-pool segment type.");
 			return 0;
 		}
-		if (!(lp->pool_data_lv_name = arg_str_value(cmd, cachepool_ARG, NULL))) {
-			log_error("Missing cache pool logical volume name.");
-			return 0;
-		}
+		lp->pool_data_lv_name = arg_str_value(cmd, cachepool_ARG, NULL);
 		cachepool = 1;
 		type_str = "cache-pool";
 	} else if (!strcmp(type_str, "cache-pool"))
@@ -259,10 +256,7 @@ static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cm
 				  " the thin or thin-pool segment type.");
 			return 0;
 		}
-		if (!(lp->pool_data_lv_name = arg_str_value(cmd, thinpool_ARG, NULL))) {
-			log_error("Missing thin pool logical volume name.");
-			return 0;
-		}
+		lp->pool_data_lv_name = arg_str_value(cmd, thinpool_ARG, NULL);
 		thinpool = 1;
 		type_str = "thin-pool";
 	} else if (!strcmp(type_str, "thin-pool"))
@@ -270,13 +264,7 @@ static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cm
 
 	if (thinpool) {
 		lp->discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_PASSDOWN);
-
-		if (arg_count(cmd, originname_ARG)) {
-			if (!(lp->origin_lv_name = arg_str_value(cmd, originname_ARG, NULL))) {
-				log_error("Missing --originname argument.");
-				return 0;
-			}
-		}
+		lp->origin_lv_name = arg_str_value(cmd, originname_ARG, NULL);
 	} else {
 		if (!arg_is_any_set(cmd, "is valid only with thin pools",
 				    discards_ARG, originname_ARG, zero_ARG,


