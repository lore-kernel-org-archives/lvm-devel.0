From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Aug 2019 06:53:18 -0400
Subject: master - pvmove: add missing synchronization
Message-ID: <201908201053.x7KArIi1017965@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0bdd6d6240251996694a8581432f726e5442c4a2
Commit:        0bdd6d6240251996694a8581432f726e5442c4a2
Parent:        0451225c1997273ffaa36c3eb595eae7737b7dda
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 20 12:23:08 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 20 12:44:39 2019 +0200

pvmove: add missing synchronization

Between 'resume' and 'remove' we need to wait for udev to synchronize,
otherwise udev may 'skip' resume event processing if the udev node
is already gone.
---
 WHATS_NEW           |    1 +
 tools/pvmove_poll.c |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 91543a7..2c1bc16 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.06 - 
 ================================
+  Add missing device synchronization point before removing pvmove node.
   Correctly set read_ahead for LVs when pvmove is finished.
   Remove unsupported OPTIONS+="event_timeout" udev rule from 11-dm-lvm.rules.
   Prevent creating VGs with PVs with different logical block sizes.
diff --git a/tools/pvmove_poll.c b/tools/pvmove_poll.c
index e50747c..d379596 100644
--- a/tools/pvmove_poll.c
+++ b/tools/pvmove_poll.c
@@ -97,6 +97,8 @@ int pvmove_finish(struct cmd_context *cmd, struct volume_group *vg,
 	if (!lv_update_and_reload(lv_mirr))
 		return_0;
 
+	sync_local_dev_names(cmd);
+
 	/* Deactivate mirror LV */
 	if (!deactivate_lv(cmd, lv_mirr)) {
 		log_error("ABORTING: Unable to deactivate temporary logical "


