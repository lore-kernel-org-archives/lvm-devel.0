From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Oct 2019 09:33:31 -0400
Subject: master - gcc: all paths will set ret
Message-ID: <201910211333.x9LDXVPD019642@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=644186e9204bfca21a6b3ca9dcc8256b93a74c15
Commit:        644186e9204bfca21a6b3ca9dcc8256b93a74c15
Parent:        f61d828c86d2b6466224290b9a1ffdaa16419f3d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 21 12:25:04 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 21 15:32:35 2019 +0200

gcc: all paths will set ret

Set success on common path.
Fixes random failure on writecache uncaching path.
---
 tools/lvconvert.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index e033e71..c312956 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4757,7 +4757,7 @@ static int _lvconvert_split_cache_single(struct cmd_context *cmd,
 			if (lvremove_single(cmd, lv_fast, NULL) != ECMD_PROCESSED)
 				return ECMD_FAILED;
 		}
-
+		ret = 1;
 	} else if (lv_is_cache(lv_main) && lv_is_cache_vol(lv_fast)) {
 		if (cmd->command->command_enum == lvconvert_split_and_remove_cache_CMD) {
 			ret = _lvconvert_split_and_remove_cachevol(cmd, lv_main, lv_fast);


