From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Dec 2018 15:47:07 -0500
Subject: master - debug: drop some extra backtraces
Message-ID: <201812212047.wBLKl78E021477@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=095c9791caa01bbfc14ac5caef45c9c5ba05e721
Commit:        095c9791caa01bbfc14ac5caef45c9c5ba05e721
Parent:        82f66834ef779414cd2c5cb258d9a45580c07009
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 21 20:24:56 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 21 21:45:08 2018 +0100

debug: drop some extra backtraces

Unneeded tracking after log_*.
---
 tools/lvconvert.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 17d7454..baabb00 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2423,7 +2423,7 @@ static int _lvconvert_cache_repair(struct cmd_context *cmd,
 
 	if (lv_is_cache(cache_lv) && lv_is_cache_single(first_seg(cache_lv)->pool_lv)) {
 		log_error("Manual repair required.");
-		return_0;
+		return 0;
 	}
 
 	pool_lv = lv_is_cache_pool(cache_lv) ? cache_lv : first_seg(cache_lv)->pool_lv;
@@ -5283,7 +5283,7 @@ static int _get_one_writecache_setting(struct cmd_context *cmd, struct writecach
 	if (!strncmp(key, "fua", strlen("fua"))) {
 		if (settings->nofua_set) {
 			log_error("Setting fua and nofua cannot both be set.");
-			return_0;
+			return 0;
 		}
 		if (sscanf(val, "%u", &settings->fua) != 1)
 			goto_bad;
@@ -5294,7 +5294,7 @@ static int _get_one_writecache_setting(struct cmd_context *cmd, struct writecach
 	if (!strncmp(key, "nofua", strlen("nofua"))) {
 		if (settings->nofua_set) {
 			log_error("Setting fua and nofua cannot both be set.");
-			return_0;
+			return 0;
 		}
 		if (sscanf(val, "%u", &settings->nofua) != 1)
 			goto_bad;
@@ -5310,7 +5310,7 @@ static int _get_one_writecache_setting(struct cmd_context *cmd, struct writecach
 	log_warn("Unrecognized writecache setting \"%s\" may cause activation failure.", key);
 	if (yes_no_prompt("Use unrecognized writecache setting? [y/n]: ") == 'n') {
 		log_error("Aborting writecache conversion.");
-		return_0;
+		return 0;
 	}
 
 	log_warn("Using unrecognized writecache setting: %s = %s.", key, val);
@@ -5356,7 +5356,7 @@ static int _get_writecache_settings(struct cmd_context *cmd, struct writecache_s
 
 			if (sscanf(str + pos, " %63[^=]=%63s %n", key, val, &num) != 2) {
 				log_error("Invalid setting at: %s", str+pos);
-				return_0;
+				return 0;
 			}
 
 			pos += num;


