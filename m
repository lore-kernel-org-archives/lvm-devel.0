From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Dec 2012 16:24:57 +0000 (UTC)
Subject: master - cleanup: convert to 32bit
Message-ID: <20121215162457.181ECAAB83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=03be45ac0a3b10807374ac0869ac8431bee348b7
Commit:        03be45ac0a3b10807374ac0869ac8431bee348b7
Parent:        0958905b1bc0a59d34a4092377bae7c59f424181
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 13 20:35:38 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 15 14:57:39 2012 +0100

cleanup: convert to 32bit

Chunk sizes fits into 4G range, so keep it in 32bit range.
---
 tools/toollib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 1d67e5d..1c455ef 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1618,7 +1618,7 @@ int update_pool_params(struct cmd_context *cmd, unsigned attr,
 				(2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE *
 				 (SECTOR_SIZE / UINT64_C(64)));
 			log_warn("WARNING: Chunk size is too small for pool, suggested minimum is %s.",
-				 display_size(cmd, 1 << (ffs(estimate_chunk_size) + 1)));
+				 display_size(cmd, 1 << (int)(ffs(estimate_chunk_size) + 1)));
 		}
 
 		/* Round up to extent size */


