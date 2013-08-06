From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  6 Aug 2013 09:47:13 +0000 (UTC)
Subject: master - thin: chunk_size check already part of get_profilable_pool_params fn
Message-ID: <20130806094713.8EA0861264@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=41e64b72ab50153494fd2925fbb760331014fd70
Commit:        41e64b72ab50153494fd2925fbb760331014fd70
Parent:        e195b5227e624cb125b070b4a10e24efdab16d53
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 6 11:46:48 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 6 11:46:48 2013 +0200

thin: chunk_size check already part of get_profilable_pool_params fn

---
 tools/toollib.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 7944d23..befd3b8 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1577,14 +1577,6 @@ int get_pool_params(struct cmd_context *cmd,
 					   chunk_size, discards, zero))
 		return_0;
 
-	if ((*chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
-	    (*chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)) {
-		log_error("Chunk size must be in the range %s to %s.",
-			  display_size(cmd, DM_THIN_MIN_DATA_BLOCK_SIZE),
-			  display_size(cmd, DM_THIN_MAX_DATA_BLOCK_SIZE));
-		return 0;
-	}
-
 	if (arg_count(cmd, poolmetadatasize_ARG)) {
 		if (arg_sign_value(cmd, poolmetadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {
 			log_error("Negative pool metadata size is invalid.");


