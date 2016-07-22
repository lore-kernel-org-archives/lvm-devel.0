From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Jul 2016 12:42:31 +0000 (UTC)
Subject: master - lvconvert: reusing old cache pool metadata needs -Zn
Message-ID: <20160722124231.7D3FD60FAC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=27a767d5e8cedf9cac31eb3562cf8fdd4aa88b7c
Commit:        27a767d5e8cedf9cac31eb3562cf8fdd4aa88b7c
Parent:        259f9dd71817ad33195384dbeca14b39dfb77ae1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 22 14:16:55 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 22 14:40:26 2016 +0200

lvconvert: reusing old cache pool metadata needs -Zn

When cache pool is reused for a new cached volume, there is
normally no need to 'keep' old cache-pool metadata as this
could cause major data lose.

Unlike with 'lvcreate -H -LX --cachepool' conversion, this lvconvert
path left the metadata unzeroed - partly for making easier some
debugging, but this was rather a bug.

So to keep possible reattach of 'unzeroed' metadata, user
now has to use 'lvconvert -Zn' for such conversion. In this case
the prompt will appear about possibe data loss and to proceed,
user has to confirm such operation. Without -Zn metadata are wiped.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   31 +++++++++++++++++++++++++++++--
 2 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 79c4317..0d6d010 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.162 - 
 =================================
+  lvconvert reuse cachepool metadade now ONLY with -Zn and clear otherwise.
   Enabled lvconvert --uncache to work with partial VG.
 
 Version 2.02.161 - 15th July 2016
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 2fd6094..9dd7254 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -372,7 +372,7 @@ static int _read_pool_params(struct cmd_context *cmd, int *pargc, char ***pargv,
 	} else {
 		if (arg_from_list_is_set(cmd, "is valid only with thin pools",
 					 discards_ARG, originname_ARG, thinpool_ARG,
-					 zero_ARG, -1))
+					 -1))
 			return_0;
 		if (lp->thin) {
 			log_error("--thin requires --thinpool.");
@@ -420,6 +420,7 @@ static int _read_pool_params(struct cmd_context *cmd, int *pargc, char ***pargv,
 
 	} else if (arg_from_list_is_set(cmd, "is valid only with pools",
 					poolmetadatasize_ARG, poolmetadataspare_ARG,
+					zero_ARG,
 					-1))
 		return_0;
 
@@ -2970,9 +2971,35 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		if (!metadata_lv) {
 			if (arg_from_list_is_set(cmd, "is invalid with existing pool",
 						 chunksize_ARG, discards_ARG,
-						 zero_ARG, poolmetadatasize_ARG, -1))
+						 poolmetadatasize_ARG, -1))
+				return_0;
+
+			if (lp->thin &&
+			    arg_from_list_is_set(cmd, "is invalid with existing thin pool",
+						 zero_ARG, -1))
 				return_0;
 
+			if (lp->cache) {
+				/* Check is user has not requested -Zn */
+				if (!arg_int_value(cmd, zero_ARG, 1)) {
+					/* Note: requires rather deep know-how to skip zeroing
+					 * so show major warnings */
+					log_warn("WARNING: Reusing old cache pool metadata %s to "
+						 "for volume caching.",
+						 display_lvname(pool_lv));
+					log_warn("THIS MAY DESTROY YOUR DATA (filesystem etc.)");
+
+					if (!lp->yes &&
+					    yes_no_prompt("Do you really want to keep old metadata for "
+							  "cache pool volume %s? [y/n]: ",
+							  display_lvname(pool_lv)) == 'n') {
+						log_error("Conversion aborted.");
+						return 0;
+					}
+				} else if (!wipe_cache_pool(pool_lv))
+					return_0;
+			}
+
 			if (lp->thin || lp->cache)
 				/* already pool, can continue converting volume */
 				return 1;


