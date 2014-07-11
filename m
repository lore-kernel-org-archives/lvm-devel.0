From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 12:54:25 +0000 (UTC)
Subject: master - lvconvert: fix missing repair option
Message-ID: <20140711125425.9BE67611B2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=65a3f50556c3544f1145d86b1b2ddd517838a950
Commit:        65a3f50556c3544f1145d86b1b2ddd517838a950
Parent:        af219fbc042db96cc588c03557614b00097ccf6c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 11 14:40:51 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 14:42:21 2014 +0200

lvconvert: fix missing repair option

Support --repair and --use-policies with mirrors.
(fixes another regression from lvconvert change for thin and cache).
TODO: the code path for mirror needs update.
---
 tools/lvconvert.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ba592a2..2ad1603 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -391,9 +391,10 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 
 	if (arg_count(cmd, repair_ARG) &&
 	    !arg_is_only_set(cmd, "cannot be used with --repair",
-			    repair_ARG,
-			    stripes_long_ARG, stripesize_ARG,
-			    -1))
+			     repair_ARG,
+			     use_policies_ARG,
+			     stripes_long_ARG, stripesize_ARG,
+			     -1))
 		return_0;
 
 	if (arg_is_set(cmd, mirrorlog_ARG) && arg_is_set(cmd, corelog_ARG)) {
@@ -617,6 +618,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 				return_0;
 		}
 	} else if (_mirror_or_raid_type_requested(cmd, type_str) ||
+		   arg_is_set(cmd, repair_ARG) ||
 		   arg_is_set(cmd, mirrorlog_ARG) ||
 		   arg_is_set(cmd, corelog_ARG)) { /* Mirrors (and some RAID functions) */
 		if (arg_count(cmd, chunksize_ARG)) {


