From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 17 Jul 2014 14:29:11 +0000 (UTC)
Subject: master - lvconvert: improve merge validation
Message-ID: <20140717142911.222D06100C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8f9f18013948f696bffaddb612d55a94f6279c9c
Commit:        8f9f18013948f696bffaddb612d55a94f6279c9c
Parent:        7abad9ef88a9c47e302a454fe15d0c9989bf89a0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 17 15:38:13 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 17 16:16:00 2014 +0200

lvconvert: improve merge validation

Easier check for conflicting options with --merge.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   15 ++++++---------
 2 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9b498b0..956b07b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.108 -
 =================================
+  Improve lvconvert --merge validation.
   Improve lvconvert --splitsnapshot validation.
   Add report/list_item_separator lvm.conf option.
   Add lv_active_{locally,remotely,exclusively} LV reporting fields.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 0f58677..e128b81 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -523,15 +523,12 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 
 	/* There are six types of lvconvert. */
 	if (lp->merge) {	/* Snapshot merge */
-		if (arg_count(cmd, regionsize_ARG) || arg_count(cmd, chunksize_ARG) ||
-		    arg_count(cmd, zero_ARG) || arg_count(cmd, regionsize_ARG) ||
-		    arg_count(cmd, poolmetadata_ARG) || arg_count(cmd, poolmetadatasize_ARG) ||
-		    arg_count(cmd, readahead_ARG) ||
-		    arg_count(cmd, stripes_long_ARG) || arg_count(cmd, stripesize_ARG)) {
-			log_error("Only --background and --interval are valid "
-				  "arguments for snapshot merge");
-			return 0;
-		}
+		if (!arg_is_only_set(cmd, "cannot be used with --merge",
+				     merge_ARG,
+				     background_ARG, interval_ARG,
+				     force_ARG, noudevsync_ARG, test_ARG,
+				     -1))
+			return_0;
 
 		if (!(lp->segtype = get_segtype_from_string(cmd, "snapshot")))
 			return_0;


