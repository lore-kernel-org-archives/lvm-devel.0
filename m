From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 17 Jul 2014 14:29:08 +0000 (UTC)
Subject: master - lvconvert: improve splitsnapshot test
Message-ID: <20140717142908.EEC406100C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7abad9ef88a9c47e302a454fe15d0c9989bf89a0
Commit:        7abad9ef88a9c47e302a454fe15d0c9989bf89a0
Parent:        4dcacbe369346e957398fd4951fc1a6d1fd4560f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 17 15:36:07 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 17 16:15:30 2014 +0200

lvconvert: improve splitsnapshot test

Easier check for conflicting options with --splitsnapshot.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   23 +++++++----------------
 2 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index db78347..9b498b0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.108 -
 =================================
+  Improve lvconvert --splitsnapshot validation.
   Add report/list_item_separator lvm.conf option.
   Add lv_active_{locally,remotely,exclusively} LV reporting fields.
   Comment out devices/{preferred_names,filter} in default lvm.conf file.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 6ec7fa5..0f58677 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -406,8 +406,14 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (arg_count(cmd, splitsnapshot_ARG))
+	if (arg_is_set(cmd, splitsnapshot_ARG)) {
+		if (!arg_is_only_set(cmd, "cannot be used with --splitsnapshot",
+				     splitsnapshot_ARG,
+				     force_ARG, noudevsync_ARG, test_ARG,
+				     -1))
+			return_0;
 		lp->splitsnapshot = 1;
+	}
 
 	if ((_snapshot_type_requested(cmd, type_str) || arg_count(cmd, merge_ARG)) &&
 	    (arg_count(cmd, mirrorlog_ARG) || _mirror_or_raid_type_requested(cmd, type_str) ||
@@ -513,21 +519,6 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 		lp->mirrors_sign = arg_sign_value(cmd, mirrors_ARG, SIGN_NONE);
 	}
 
-	if (lp->splitsnapshot &&
-	    (lp->snapshot || lp->thin || lp->merge || lp->merge_mirror || arg_count(cmd, thinpool_ARG) ||
-	     arg_count(cmd, mirrors_ARG) || arg_count(cmd, repair_ARG) || arg_count(cmd, replace_ARG) ||
-	     arg_count(cmd, chunksize_ARG) || arg_count(cmd, zero_ARG) || arg_count(cmd, regionsize_ARG) ||
-	     arg_count(cmd, poolmetadata_ARG) || arg_count(cmd, poolmetadatasize_ARG) ||
-	     arg_count(cmd, readahead_ARG) || arg_count(cmd, stripes_long_ARG) ||
-	     arg_count(cmd, stripesize_ARG) || arg_count(cmd, background_ARG) ||
-	     arg_count(cmd, interval_ARG) || arg_count(cmd, type_ARG) || arg_count(cmd, alloc_ARG) ||
-	     arg_count(cmd, corelog_ARG) || arg_count(cmd, mirrorlog_ARG) ||
-	     arg_count(cmd, splitmirrors_ARG) || arg_count(cmd, originname_ARG) ||
-	     arg_count(cmd, trackchanges_ARG) || arg_count(cmd, use_policies_ARG))) {
-		log_error("Incompatible arguments supplied with --splitsnapshot.");
-		return 0;
-	}
-
 	lp->alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
 
 	/* There are six types of lvconvert. */


