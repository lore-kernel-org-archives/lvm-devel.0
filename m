From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  6 Aug 2013 14:29:56 +0000 (UTC)
Subject: master - thin: fix commit e195b5227e624cb125b070b4a10e24efdab16d53
Message-ID: <20130806142956.422A160D3D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f74e8fe04471a44fe1ab0645e48c9cb06ef6fb4f
Commit:        f74e8fe04471a44fe1ab0645e48c9cb06ef6fb4f
Parent:        003f08c1642f060e57c55e950d4690d470451602
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 6 16:28:12 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 6 16:28:12 2013 +0200

thin: fix commit e195b5227e624cb125b070b4a10e24efdab16d53

Check chunk_size range unconditionally.
---
 lib/metadata/thin_manip.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 36cd6c4..971ffe6 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -575,15 +575,15 @@ int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profi
 {
 	const char *dstr;
 
-	if (!(passed_args & PASS_ARG_CHUNK_SIZE)) {
+	if (!(passed_args & PASS_ARG_CHUNK_SIZE))
 		*chunk_size = find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG, profile) * 2;
-		if ((*chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
-		    (*chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)) {
-			log_error("Chunk size must be in the range %s to %s.",
-				  display_size(cmd, DM_THIN_MIN_DATA_BLOCK_SIZE),
-				  display_size(cmd, DM_THIN_MAX_DATA_BLOCK_SIZE));
-			return 0;
-		}
+
+	if ((*chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
+	    (*chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)) {
+		log_error("Chunk size must be in the range %s to %s.",
+			  display_size(cmd, DM_THIN_MIN_DATA_BLOCK_SIZE),
+			  display_size(cmd, DM_THIN_MAX_DATA_BLOCK_SIZE));
+		return 0;
 	}
 
 	if (!(passed_args & PASS_ARG_DISCARDS)) {


