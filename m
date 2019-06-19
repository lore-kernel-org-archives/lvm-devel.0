From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 19 Jun 2019 07:41:58 -0400
Subject: stable-2.02 - mirror: fix monitoring change
Message-ID: <201906191141.x5JBfwdN017322@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d6bce036155ae973c869bdce3ca5f824f933f599
Commit:        d6bce036155ae973c869bdce3ca5f824f933f599
Parent:        8623e336513c6ac6fcb24aa7e2ef10b8a3a36c59
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 19 12:42:01 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 19 13:33:53 2019 +0200

mirror: fix monitoring change

Commit a8921be641afe865c177e11b8859f4b937f76995 was supposedly a fix
for unwanted table reload - however before final commit, the tiny
change has been made that was believed to be an enhancment
of original prepared patch. Unfortunatelly the function
locking_is_clustered is not meant to be an equivalent test
of original function.  Drop this change and using
original patch.
---
 lib/activate/activate.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index dc9bc9e..b3b8a25 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2048,12 +2048,12 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 		} else
 			continue;
 
-		if (!locking_is_clustered() && !vg_write_lock_held() && lv_is_mirror(lv)) {
+		if (!cmd->is_clvmd && !vg_write_lock_held() && lv_is_mirror(lv)) {
 			/*
 			 * Commands vgchange and lvchange do use read-only lock when changing
 			 * monitoring (--monitor y|n). All other use cases hold 'write-lock'
 			 * so they skip this dm mirror table refreshing step.
-			 * Shortcut can't be applied with clustered locking.
+			 * Shortcut is also not applied with clvmd.
 			 */
 			if (!_lv_activate_lv(lv, &mirr_laopts)) {
 				stack;


