From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 11:34:28 +0000 (UTC)
Subject: master - lvconvert: relocate mirror tests
Message-ID: <20140711113428.85B936105E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=04b8e55f2a2a96d2ffbd124fe3c0fc7c452cfb26
Commit:        04b8e55f2a2a96d2ffbd124fe3c0fc7c452cfb26
Parent:        1931d1e58e1b7af8251d96ed84694c3ba5c7352e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 10 22:02:54 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 12:57:45 2014 +0200

lvconvert: relocate mirror tests

---
 tools/lvconvert.c |   25 ++++++++++++-------------
 1 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 264b86c..2892d00 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -236,6 +236,18 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 	if (!_check_conversion_type(cmd, type_str))
 		return_0;
 
+	if (arg_count(cmd, repair_ARG) &&
+	    !arg_is_only_set(cmd, "cannot be used with --repair",
+			    repair_ARG,
+			    stripes_long_ARG, stripesize_ARG,
+			    -1))
+		return_0;
+
+	if (arg_is_set(cmd, mirrorlog_ARG) && arg_is_set(cmd, corelog_ARG)) {
+		log_error("--mirrorlog and --corelog are incompatible.");
+		return 0;
+	}
+
 	if (arg_count(cmd, splitsnapshot_ARG))
 		lp->splitsnapshot = 1;
 
@@ -1273,19 +1285,6 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 		return 1;
 	}
 
-	if ((arg_count(cmd, mirrors_ARG) && repair) ||
-	    (arg_count(cmd, mirrorlog_ARG) && repair) ||
-	    (arg_count(cmd, corelog_ARG) && repair)) {
-		log_error("--repair cannot be used with --mirrors, --mirrorlog,"
-			  " or --corelog");
-		return 0;
-	}
-
-	if (arg_count(cmd, mirrorlog_ARG) && arg_count(cmd, corelog_ARG)) {
-		log_error("--mirrorlog and --corelog are incompatible");
-		return 0;
-	}
-
 	/*
 	 * Adjusting mimage count?
 	 */


