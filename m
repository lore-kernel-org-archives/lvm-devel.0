From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Oct 2016 11:39:34 +0000 (UTC)
Subject: master - cleanup: indent
Message-ID: <20161011113934.6D1DE61152@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8f300691603c57388a4fa092f18f121d7504e3c4
Commit:        8f300691603c57388a4fa092f18f121d7504e3c4
Parent:        6f576483a87aac67037e25914990a77e76c81423
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 11 11:55:19 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 11 13:37:43 2016 +0200

cleanup: indent

---
 tools/lvconvert.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 78cd7de..48e8cc8 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -330,6 +330,7 @@ static int _read_conversion_type(struct cmd_context *cmd,
 		return 1;
 
 	log_error("Conversion using --type %s is not supported.", type_str);
+
 	return 0;
 }
 
@@ -561,7 +562,6 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 			log_error("--snapshot and --merge are mutually exclusive.");
 			return 0;
 		}
-
 		lp->snapshot = 1;
 	}
 
@@ -627,9 +627,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	}
 
 	if (arg_is_set(cmd, mirrors_ARG)) {
-		/*
-		 * --splitmirrors is the mechanism for detaching and keeping a mimage
-		 */
+		/* --splitmirrors is the mechanism for detaching and keeping a mimage */
 		lp->mirrors_supplied = 1;
 		lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0);
 		lp->mirrors_sign = arg_sign_value(cmd, mirrors_ARG, SIGN_NONE);
@@ -4272,6 +4270,7 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 			 struct lvconvert_params *lp)
 {
 	/* Permitted convert options on visible or hidden RaidLVs */
+	/* The --thinpool alternative for --type thin-pool is not preferred, so not shown. */
 	const char *permitted_options = lv_is_visible(lv) ?
 	  	"  --mirrors\n"
 	  	"  --splitmirrors\n"
@@ -4347,13 +4346,12 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 		if (segtype_is_cache_pool(lp->segtype) ||
 		    arg_is_set(cmd, cachepool_ARG))
 			return _convert_raid_cache_pool(cmd, lv, lp);
-
-		/* The --thinpool alternative for --type thin-pool is not preferred, so not shown. */
 	}
 
 out:
 	log_error("Operation not permitted on raid LV %s.", display_lvname(lv));
 	log_error("Operations permitted on a raid LV are:\n%s", permitted_options);
+
 	return 0;
 }
 


