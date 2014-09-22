From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:38:56 +0000 (UTC)
Subject: dev-dct-process-latest - lvconvert: Disallow mixing of cache and thin pools.
Message-ID: <20140922153856.35A5A61087@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a2a869afc8f55409fca0f2079facaf57f2539f24
Commit:        a2a869afc8f55409fca0f2079facaf57f2539f24
Parent:        bdb05cc05e3a0eac72b0921cb5eb500891346e12
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Sep 17 17:11:01 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Sep 17 17:11:01 2014 +0100

lvconvert: Disallow mixing of cache and thin pools.

--cachepool can't take a thin pool and --thinpool can't take a
cache pool.
---
 tools/lvconvert.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 295a4e5..eb96bc4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2733,6 +2733,18 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 	if (lv_is_pool(pool_lv)) {
 		lp->pool_data_lv = pool_lv;
 
+		if (arg_is_set(cmd, cachepool_ARG) && lv_is_thin_pool(pool_lv)) {
+			log_error("--cachepool requires a cache pool.  %s is a thin pool.",
+				  display_lvname(pool_lv));
+			return 0;
+		}
+
+		if (arg_is_set(cmd, thinpool_ARG) && lv_is_cache_pool(pool_lv)) {
+			log_error("--thinpool requires a thin pool.  %s is a cache pool.",
+				  display_lvname(pool_lv));
+			return 0;
+		}
+
 		if (!metadata_lv) {
 			if (arg_from_list_is_set(cmd, "is invalid with existing pool",
 						 cachemode_ARG,chunksize_ARG, discards_ARG,


