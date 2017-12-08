From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 8 Dec 2017 07:22:02 -0500
Subject: master - vgchange: drop extra counting
Message-ID: <201712081222.vB8CM2go007320@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4e8af1d3aa136eae8dbb66186bfc331b0b2887e6
Commit:        4e8af1d3aa136eae8dbb66186bfc331b0b2887e6
Parent:        14b1e5270dbca71870a79b37d6614e2cb96b180f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 8 13:17:34 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 8 13:21:14 2017 +0100

vgchange: drop extra counting

As the loop for background polling _poll_lvs_in_vg checks for active LVs,
avoid doing unnecessary extra check before.
---
 WHATS_NEW        |    1 +
 tools/vgchange.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4659d55..db256b0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Reduce checks for active LVs in vgchange before background polling.
   Ensure _node_send_message always uses clean status of thin pool.
   Fix lvmlockd to use pool lock when accessing _tmeta volume.
   Report expected sanlock_convert errors only when retries fail.
diff --git a/tools/vgchange.c b/tools/vgchange.c
index ae97a4a..48e64c5 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -178,7 +178,7 @@ int vgchange_background_polling(struct cmd_context *cmd, struct volume_group *vg
 {
 	int polled;
 
-	if (lvs_in_vg_activated(vg) && background_polling()) {
+	if (background_polling()) {
 	        polled = _poll_lvs_in_vg(cmd, vg);
 		if (polled)
 			log_print_unless_silent("Background polling started for %d logical volume(s) "


