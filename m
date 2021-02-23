From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 23 Feb 2021 14:04:15 +0000 (GMT)
Subject: main - cache: fix warning test
Message-ID: <20210223140415.4A4683938399@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b140bba9fe69f3bd4c89f15998b3e197fe9bf428
Commit:        b140bba9fe69f3bd4c89f15998b3e197fe9bf428
Parent:        ac09fa08aa7a10cc3f807830de5d625d499ed1b1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 20 22:45:13 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 14:56:47 2021 +0100

cache: fix warning test

The cache here is not 'writethough' - so print proper state
(writeback or passthrough)
---
 tools/lvconvert.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 8bd73bb53..83bdfd04b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2032,8 +2032,8 @@ static int _lvconvert_split_and_remove_cachepool(struct cmd_context *cmd,
 					  display_lvname(lv));
 				return 0;
 			}
-			log_warn("WARNING: Uncaching of partially missing writethrough cache volume %s might destroy your data.",
-				 display_lvname(lv));
+			log_warn("WARNING: Uncaching of partially missing %s cache volume %s might destroy your data.",
+				 cache_mode_num_to_str(first_seg(seg->pool_lv)->cache_mode), display_lvname(lv));
 		}
 
 		if (!arg_count(cmd, yes_ARG) &&


