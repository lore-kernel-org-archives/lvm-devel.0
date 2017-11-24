From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 24 Nov 2017 10:11:28 -0500
Subject: master - cleanup: using max args consistently
Message-ID: <201711241511.vAOFBSDi000770@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b0398f42ad125ca084e2b6942e23cacaafabd98e
Commit:        b0398f42ad125ca084e2b6942e23cacaafabd98e
Parent:        54741aeac5e45abbad26343776a6205dab85b0fb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 21 17:36:09 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 24 16:09:59 2017 +0100

cleanup: using max args consistently

Define and use MAX_PDATA_ARGS for thin_repair and cache_repair consistently.
---
 tools/lvconvert.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ed1a130..d5491a7 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -18,6 +18,8 @@
 #include "lv_alloc.h"
 #include "lvconvert_poll.h"
 
+#define MAX_PDATA_ARGS	10	/* Max number of accepted args for d-m-p-d tools */
+
 typedef enum {
 	/* Split:
 	 *   For a mirrored or raid LV, split mirror into two mirrors, optionally tracking
@@ -2204,7 +2206,7 @@ static int _lvconvert_thin_pool_repair(struct cmd_context *cmd,
 	const struct dm_config_value *cv;
 	int ret = 0, status;
 	int args = 0;
-	const char *argv[19]; /* Max supported 10 args */
+	const char *argv[MAX_PDATA_ARGS + 7]; /* Max supported args */
 	char *dm_name, *trans_id_str;
 	char meta_path[PATH_MAX];
 	char pms_path[PATH_MAX];
@@ -2250,7 +2252,7 @@ static int _lvconvert_thin_pool_repair(struct cmd_context *cmd,
 		return 0;
 	}
 
-	for (cv = cn->v; cv && args < 16; cv = cv->next) {
+	for (cv = cn->v; cv && args < MAX_PDATA_ARGS; cv = cv->next) {
 		if (cv->type != DM_CFG_STRING) {
 			log_error("Invalid string in config file: "
 				  "global/thin_repair_options");
@@ -2259,7 +2261,7 @@ static int _lvconvert_thin_pool_repair(struct cmd_context *cmd,
 		argv[++args] = cv->v.str;
 	}
 
-	if (args == 10) {
+	if (args >= MAX_PDATA_ARGS) {
 		log_error("Too many options for thin repair command.");
 		return 0;
 	}
@@ -2401,7 +2403,7 @@ static int _lvconvert_cache_repair(struct cmd_context *cmd,
 	const struct dm_config_value *cv;
 	int ret = 0, status;
 	int args = 0;
-	const char *argv[19]; /* Max supported 10 args */
+	const char *argv[MAX_PDATA_ARGS + 7]; /* Max supported args */
 	char *dm_name;
 	char meta_path[PATH_MAX];
 	char pms_path[PATH_MAX];
@@ -2448,7 +2450,7 @@ static int _lvconvert_cache_repair(struct cmd_context *cmd,
 		return 0;
 	}
 
-	for (cv = cn->v; cv && args < 16; cv = cv->next) {
+	for (cv = cn->v; cv && args < MAX_PDATA_ARGS; cv = cv->next) {
 		if (cv->type != DM_CFG_STRING) {
 			log_error("Invalid string in config file: "
 				  "global/cache_repair_options");
@@ -2457,7 +2459,7 @@ static int _lvconvert_cache_repair(struct cmd_context *cmd,
 		argv[++args] = cv->v.str;
 	}
 
-	if (args == 10) {
+	if (args >= MAX_PDATA_ARGS) {
 		log_error("Too many options for cache repair command.");
 		return 0;
 	}


