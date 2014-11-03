From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:23:32 +0000 (UTC)
Subject: master - thin: allow to convert chunksize of empty pool
Message-ID: <20141103132332.44262602D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=127cf4895a8531e1ffcae06ce472c9ecf3b94f2c
Commit:        127cf4895a8531e1ffcae06ce472c9ecf3b94f2c
Parent:        7f35d42a99db9dedc3f2f6fb9f65873704a241ef
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 3 14:00:09 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:33 2014 +0100

thin: allow to convert chunksize of empty pool

When pool is not used, allow to change its chunksize.
---
 tools/lvconvert.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index f22c84b..f37a7a8 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2923,7 +2923,8 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 
 		/* Normally do NOT change chunk size when swapping */
 		if (arg_count(cmd, chunksize_ARG) &&
-		    (lp->chunk_size != seg->chunk_size)) {
+		    (lp->chunk_size != seg->chunk_size) &&
+		    !dm_list_empty(&pool_lv->segs_using_this_lv)) {
 			if (lp->force == PROMPT) {
 				log_error("Chunk size can be only changed with --force. Conversion aborted.");
 				return 0;


