From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  2 Jul 2014 13:12:18 +0000 (UTC)
Subject: master - cleanup: drop inline and add prefix _ for static
Message-ID: <20140702131218.291CD61026@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=39bd6bb89e364e72808870e2ad88ddf79b591a3f
Commit:        39bd6bb89e364e72808870e2ad88ddf79b591a3f
Parent:        d1094ec4c662bef5e11bc67578d3fa4607940b93
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 2 15:09:06 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 2 15:09:06 2014 +0200

cleanup: drop inline and add prefix _ for static

Leave inline decision on compiler.
Add '_'prefix for static functions.
---
 tools/lvconvert.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4f29416..2a2a398 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -211,11 +211,11 @@ static int _check_conversion_type(struct cmd_context *cmd, const char *type_str)
 }
 
 /* -s/--snapshot and --type snapshot are synonyms */
-static inline int snapshot_type_requested(struct cmd_context *cmd, const char *type_str) {
+static int _snapshot_type_requested(struct cmd_context *cmd, const char *type_str) {
 	return (arg_count(cmd, snapshot_ARG) || !strcmp(type_str, "snapshot"));
 }
 /* mirror/raid* (1,10,4,5,6 and their variants) reshape */
-static inline int mirror_or_raid_type_requested(struct cmd_context *cmd, const char *type_str) {
+static int _mirror_or_raid_type_requested(struct cmd_context *cmd, const char *type_str) {
 	return (arg_count(cmd, mirrors_ARG) || !strncmp(type_str, "raid", 4) || !strcmp(type_str, "mirror"));
 }
 
@@ -239,8 +239,8 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 	if (arg_count(cmd, splitsnapshot_ARG))
 		lp->splitsnapshot = 1;
 
-	if ((snapshot_type_requested(cmd, type_str) || arg_count(cmd, merge_ARG)) &&
-	    (arg_count(cmd, mirrorlog_ARG) || mirror_or_raid_type_requested(cmd, type_str) ||
+	if ((_snapshot_type_requested(cmd, type_str) || arg_count(cmd, merge_ARG)) &&
+	    (arg_count(cmd, mirrorlog_ARG) || _mirror_or_raid_type_requested(cmd, type_str) ||
 	     arg_count(cmd, repair_ARG) || arg_count(cmd, thinpool_ARG))) {
 		log_error("--snapshot/--type snapshot or --merge argument "
 			  "cannot be mixed with --mirrors/--type mirror/--type raid*, "
@@ -249,7 +249,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 	}
 
 	if ((arg_count(cmd, stripes_long_ARG) || arg_count(cmd, stripesize_ARG)) &&
-	    !(mirror_or_raid_type_requested(cmd, type_str) ||
+	    !(_mirror_or_raid_type_requested(cmd, type_str) ||
 	      arg_count(cmd, repair_ARG) ||
 	      arg_count(cmd, thinpool_ARG))) {
 		log_error("--stripes or --stripesize argument is only valid "
@@ -274,15 +274,15 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 	if (!arg_count(cmd, background_ARG))
 		lp->wait_completion = 1;
 
-	if (snapshot_type_requested(cmd, type_str))
+	if (_snapshot_type_requested(cmd, type_str))
 		lp->snapshot = 1;
 
-	if (snapshot_type_requested(cmd, type_str) && arg_count(cmd, merge_ARG)) {
+	if (_snapshot_type_requested(cmd, type_str) && arg_count(cmd, merge_ARG)) {
 		log_error("--snapshot and --merge are mutually exclusive");
 		return 0;
 	}
 
-	if (arg_count(cmd, splitmirrors_ARG) && mirror_or_raid_type_requested(cmd, type_str)) {
+	if (arg_count(cmd, splitmirrors_ARG) && _mirror_or_raid_type_requested(cmd, type_str)) {
 		log_error("--mirrors/--type mirror/--type raid* and --splitmirrors are "
 			  "mutually exclusive");
 		return 0;
@@ -304,7 +304,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 				  cache_pool ? "type cache_" : "thin");
 			return 0;
 		}
-		if (mirror_or_raid_type_requested(cmd, type_str)) {
+		if (_mirror_or_raid_type_requested(cmd, type_str)) {
 			log_error("--%spool and --mirrors/--type mirror/--type raid* are mutually exlusive.",
 				  cache_pool ? "type cache_" : "thin");
 			return 0;
@@ -314,7 +314,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 				  cache_pool ? "type cache_" : "thin");
 			return 0;
 		}
-		if (snapshot_type_requested(cmd, type_str)) {
+		if (_snapshot_type_requested(cmd, type_str)) {
 			log_error("--%spool and --snapshot/--type snapshot are mutually exlusive.",
 				  cache_pool ? "type cache_" : "thin");
 			return 0;


