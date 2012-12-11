From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Dec 2012 10:26:45 +0000 (UTC)
Subject: master - thin: remove detection for thin discard support
Message-ID: <20121211102645.43AAC1465@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ed65860861edcb5cd41656b05833defef5d592d0
Commit:        ed65860861edcb5cd41656b05833defef5d592d0
Parent:        ec49f07b0dc89720f4a74a1212e106990099d2d6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 10 10:22:16 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 11 11:24:45 2012 +0100

thin: remove detection for thin discard support

Remove no longer needed warning for unsuppoted discards
for non-power-2 lvcreate commands.

(Missed from the patch for the same update in lvchange made
by commit dde5a6c52b315d7b)
---
 tools/toollib.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 4c9a43d..817580f 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1596,10 +1596,6 @@ int update_pool_params(struct cmd_context *cmd, unsigned attr,
 		log_error("Chunk size must be multiple of %s.",
 			  display_size(cmd, DM_THIN_MIN_DATA_BLOCK_SIZE));
 		return 0;
-	} else if ((*discards != THIN_DISCARDS_IGNORE) &&
-		   (*chunk_size & (*chunk_size - 1))) {
-		log_warn("WARNING: Using discards ignore for chunk size non power of 2.");
-		*discards = THIN_DISCARDS_IGNORE;
 	}
 
 	if (!*pool_metadata_size) {


