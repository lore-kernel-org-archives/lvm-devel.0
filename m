From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  1 Sep 2020 17:01:57 +0000 (GMT)
Subject: master - cachevol: correcting 64b math
Message-ID: <20200901170157.5FAB73870890@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ef389603ddd1239c79f688bac0bb7b27a568df6e
Commit:        ef389603ddd1239c79f688bac0bb7b27a568df6e
Parent:        f0614e7cf05df969f9789f0746b820ce5cbb33a2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Aug 29 20:08:49 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 1 17:50:48 2020 +0200

cachevol: correcting 64b math

Widen to 64bit for correct 64b multiplication math.
---
 WHATS_NEW         | 1 +
 tools/lvconvert.c | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d433ddf9a..3c84ea867 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.11 - 
 ==================================
+  Fix 64bit math when calculation cachevol size.
   Preserve uint32_t for seqno handling.
   Switch from mmap to plain read when loading regular files.
   Fix missing device closing on wiping error path.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index afc581377..c95287a78 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4333,7 +4333,7 @@ static int _lv_create_cachevol(struct cmd_context *cmd,
 		}
 
 		if (!cache_size_sectors) {
-			pv_size_sectors = (pvl->pv->pe_count * vg->extent_size);
+			pv_size_sectors = (pvl->pv->pe_count * (uint64_t)vg->extent_size);
 
 			if (!arg_is_set(cmd, yes_ARG) &&
 			    yes_no_prompt("Use all %s from %s for cache? [y/n]: ",


