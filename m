From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:23:28 +0000 (UTC)
Subject: master - pool: validate sizes
Message-ID: <20141103132328.18700602D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=897b09157922a510d6c9f5556eea4fc243b84702
Commit:        897b09157922a510d6c9f5556eea4fc243b84702
Parent:        dc11dcf11d90f24c8d37988f3029e29cc6a45441
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 31 11:41:49 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:32 2014 +0100

pool: validate sizes

0 size are not supported as well as negative.
---
 tools/toollib.c |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index dd09811..e87fd30 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -975,12 +975,21 @@ int get_pool_params(struct cmd_context *cmd,
 		}
 	}
 
-	if (arg_count(cmd, chunksize_ARG)) {
-		if (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS) {
-			log_error("Negative chunk size is invalid.");
-			return 0;
-		}
+	if (arg_from_list_is_negative(cmd, "may not be negative",
+				      chunksize_ARG,
+				      pooldatasize_ARG,
+				      poolmetadatasize_ARG,
+				      -1))
+		return_0;
+
+	if (arg_from_list_is_zero(cmd, "may not be zero",
+				  chunksize_ARG,
+				  pooldatasize_ARG,
+				  poolmetadatasize_ARG,
+				  -1))
+		return_0;
 
+	if (arg_is_set(cmd, chunksize_ARG)) {
 		*passed_args |= PASS_ARG_CHUNK_SIZE;
 		*chunk_size = arg_uint_value(cmd, chunksize_ARG, 0);
 


