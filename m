From: David Teigland <teigland@sourceware.org>
Date: Thu, 17 Jun 2021 21:18:24 +0000 (GMT)
Subject: main - lvconvert: allow writecache with other thinpool command syntax
Message-ID: <20210617211824.EBEBC385782A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c35f7722d588009edad22d59c68c82150bb5c216
Commit:        c35f7722d588009edad22d59c68c82150bb5c216
Parent:        f7730406254f023216d0727c82d46de82c124c92
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 17 16:15:18 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 17 16:15:18 2021 -0500

lvconvert: allow writecache with other thinpool command syntax

"lvconvert --thinpool LV" should allow LV to have a writecache,
but there was an extra type check preventing it.
---
 tools/lvconvert.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index e19c445b1..cbe4fa93a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4769,7 +4769,7 @@ static int _lvconvert_to_pool_or_swap_metadata_single(struct cmd_context *cmd,
 
 	switch (cmd->command->command_enum) {
 	case lvconvert_to_thinpool_or_swap_metadata_CMD:
-		if (lv_is_cache(lv))
+		if (lv_is_cache(lv) || lv_is_writecache(lv))
 			/* For cached LV check the cache origin LV type */
 			lvt_enum = get_lvt_enum(seg_lv(first_seg(lv), 0));
 		to_thinpool = 1;


