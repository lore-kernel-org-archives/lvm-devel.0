From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 27 Jul 2016 14:21:36 +0000 (UTC)
Subject: master - lvconvert: support --zero for full cache pool conversion.
Message-ID: <20160727142136.2385160268@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eaf7d06a82aef60cd4f0dec2f858998f215c4417
Commit:        eaf7d06a82aef60cd4f0dec2f858998f215c4417
Parent:        3c377f8334491421207ae91094e9d7b3be0a300f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 27 16:14:47 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 27 16:20:57 2016 +0200

lvconvert: support --zero for full cache pool conversion.

Add matching support for -Z option also we doing full conversion
to cache-pool.

Extending coversion message to show which pool type is created
and whether the metadata will be wiped or remain unmodified.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   39 ++++++++++++++++++++++++++++-----------
 2 files changed, 29 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5c09a1f..25d3b83 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.162 - 
 =================================
+  Support lvconvert -Zn also when doing full cache pool conversion.
   Suppress not zeroing warn when converting to thin LV for non-zeroing tpool.
   Fix automatic updates of PV extension headers to newest version.
   Improve lvconvert --trackchanges validation to require --splitmirrors 1.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index f3586b2..62c21bd 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2851,6 +2851,7 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 	struct id lockd_data_id;
 	struct id lockd_meta_id;
 	char metadata_name[NAME_LEN], data_name[NAME_LEN];
+	int zero_metadata = 1;
 	int activate_pool;
 
 	if (lp->pool_data_name) {
@@ -3091,12 +3092,26 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 			return 0;
 		}
 	} else {
-		log_warn("WARNING: Converting logical volume %s%s%s to pool's data%s.",
+		/* Only cache pool conversion may suppress metadata zeroing
+		 * TODO: Maybe similar support could be useful for thin-pool, but --zero
+		 * is already overloade and we would also need to possibly match transaction Id. */
+		if (segtype_is_cache_pool(lp->segtype) && metadata_lv)
+			/* Check is user requested zeroing logic via [-Z y|n] (default is yes) */
+			zero_metadata = arg_int_value(cmd, zero_ARG, 1);
+
+		log_warn("WARNING: Converting logical volume %s%s%s to %s pool's data%s %s metadata wiping.",
 			 display_lvname(pool_lv),
 			 metadata_lv ? " and " : "",
 			 metadata_lv ? display_lvname(metadata_lv) : "",
-			 metadata_lv ? " and metadata volumes" : " volume");
-		log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
+			 segtype_is_cache_pool(lp->segtype) ? "cache" : "thin",
+			 metadata_lv ? " and metadata volumes" : " volume",
+			 zero_metadata ? "with" : "WITHOUT");
+
+		if (zero_metadata)
+			log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
+		else /* ATM supported only for cache pools */
+			log_warn("WARNING: Using mismatched cache pool metadata "
+				 "MAY DESTROY YOUR DATA!");
 
 		if (!lp->yes &&
 		    yes_no_prompt("Do you really want to convert %s%s%s? [y/n]: ",
@@ -3168,15 +3183,17 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 			goto mda_write;
 		}
 
-		metadata_lv->status |= LV_TEMPORARY;
-		if (!activate_lv_local(cmd, metadata_lv)) {
-			log_error("Aborting. Failed to activate metadata lv.");
-			return 0;
-		}
+		if (zero_metadata) {
+			metadata_lv->status |= LV_TEMPORARY;
+			if (!activate_lv_local(cmd, metadata_lv)) {
+				log_error("Aborting. Failed to activate metadata lv.");
+				return 0;
+			}
 
-		if (!wipe_lv(metadata_lv, (struct wipe_params) { .do_zero = 1 })) {
-			log_error("Aborting. Failed to wipe metadata lv.");
-			return 0;
+			if (!wipe_lv(metadata_lv, (struct wipe_params) { .do_zero = 1 })) {
+				log_error("Aborting. Failed to wipe metadata lv.");
+				return 0;
+			}
 		}
 	}
 


