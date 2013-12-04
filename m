From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  4 Dec 2013 02:05:24 +0000 (UTC)
Subject: master - lvconvert: Fix reload after snapshot conversion.
Message-ID: <20131204020524.78A7B60D90@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ff769ecfe7cdd704ee1e11aa9b6b7a92f932a0c1
Commit:        ff769ecfe7cdd704ee1e11aa9b6b7a92f932a0c1
Parent:        6232cac86cea332efb1e538fc8cd1922dc35bd01
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Dec 4 02:04:29 2013 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Dec 4 02:04:29 2013 +0000

lvconvert: Fix reload after snapshot conversion.

At the end of lvconvert --snapshot with an active origin, the origin
gets reloaded.

Commit 57c0f72b1d0349382c226c2b5614489b59db99e8 ("lvconvert: use
_reload_lv on more places") accidentally replaced this with a snapshot
LV reload (which does nothing because only the origin is active).
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c91acff..c96acce 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Reinstate origin reload to complete lvconvert -s with active LVs. (2.02.98)
   Select only active volume groups if vgdisplay -A is used.
   Add -p and LVM_LVMETAD_PID env var to lvmetad to change pid file.
   Allow lvmetad to reuse stale socket.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 6f81356..b040e33 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1864,7 +1864,7 @@ static int lvconvert_snapshot(struct cmd_context *cmd,
 	}
 
 	/* store vg on disk(s) */
-	if (!_reload_lv(cmd, lv->vg, lv))
+	if (!_reload_lv(cmd, lv->vg, org))
 		return_0;
 
 	log_print_unless_silent("Logical volume %s converted to snapshot.", lv->name);


