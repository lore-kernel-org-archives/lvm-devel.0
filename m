From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 25 Jul 2018 05:38:10 -0400
Subject: 2018-06-01-stable - lvconvert: reject conversions of LVs under snapshot
Message-ID: <201807250938.w6P9cA18028828@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4456d9aa77de7ac035ab975d87b0696e33370ab4
Commit:        4456d9aa77de7ac035ab975d87b0696e33370ab4
Parent:        b394a9f63fd01c926c8c00d78f43afb223b2d203
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Jul 23 19:20:18 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Jul 25 10:52:58 2018 +0200

lvconvert: reject conversions of LVs under snapshot

Conversions of LVs under snapshot to thinpool or cachepool
correctly fail but leave them inactive and provide cryptic
error messages like 'Internal error: #LVs (10) != #visible
LVs (2) + #snapshots (1) + #internal LVs (5) in VG VG'.

Reject and provide better error message.

Resolves: rhbz1514146
(cherry picked from commit 2214dc12c34890c78b05456f58d0aa5d6dd08f4c)
---
 tools/lvconvert.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index b149201..11715bd 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4251,6 +4251,12 @@ static int _lvconvert_to_pool_or_swap_metadata_single(struct cmd_context *cmd,
 		return 0;
 	};
 
+	if (lv_is_origin(lv)) {
+		log_error("Cannot convert logical volume %s under snapshot.",
+			  display_lvname(lv));
+		return 0;
+	};
+
 	if (cmd->position_argc > 1) {
 		/* First pos arg is required LV, remaining are optional PVs. */
 		if (!(use_pvh = create_pv_list(cmd->mem, lv->vg, cmd->position_argc - 1, cmd->position_argv + 1, 0)))


