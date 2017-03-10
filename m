From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:35:13 -0500
Subject: master - pool: drop duplicated sign test
Message-ID: <201703101835.v2AIZD96027114@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8c72878cf2f53811cf5ae6fc9b7c787feb74e0c6
Commit:        8c72878cf2f53811cf5ae6fc9b7c787feb74e0c6
Parent:        acfc82ae29eea2b107fb97e4d6fd350b3347f925
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 9 17:09:31 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:00 2017 +0100

pool: drop duplicated sign test

Avoid duplicate testing of '-' sign.
Already checked with arg_from_list_is_negative().
---
 tools/toollib.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index f2951a7..c10f5ca 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1243,11 +1243,6 @@ int get_pool_params(struct cmd_context *cmd,
 	}
 
 	if (arg_is_set(cmd, poolmetadatasize_ARG)) {
-		if (arg_sign_value(cmd, poolmetadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {
-			log_error("Negative pool metadata size is invalid.");
-			return 0;
-		}
-
 		if (arg_is_set(cmd, poolmetadata_ARG)) {
 			log_error("Please specify either metadata logical volume or its size.");
 			return 0;


