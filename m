From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  5 Feb 2013 13:47:33 +0000 (UTC)
Subject: master - cleanup: avoid overflow warning
Message-ID: <20130205134733.74B81A0C2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7cd25062acc5c54959e892381600257372ef071f
Commit:        7cd25062acc5c54959e892381600257372ef071f
Parent:        d7ea12f222bb40d0bdd523a6072c5771053f75c1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 4 20:32:21 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 5 14:27:25 2013 +0100

cleanup: avoid overflow warning

Even we do not expect to support chunks bigger then 2GB.
---
 tools/toollib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 669d772..1abe837 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1617,7 +1617,7 @@ int update_pool_params(struct cmd_context *cmd, unsigned attr,
 				(2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE *
 				 (SECTOR_SIZE / UINT64_C(64)));
 			log_warn("WARNING: Chunk size is too small for pool, suggested minimum is %s.",
-				 display_size(cmd, 1 << (int)(ffs(estimate_chunk_size) + 1)));
+				 display_size(cmd, UINT64_C(1) << (ffs(estimate_chunk_size) + 1)));
 		}
 
 		/* Round up to extent size */


