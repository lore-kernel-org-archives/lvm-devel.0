From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Nov 2017 08:09:43 -0500
Subject: master - activate_lvs: deactivate on uniterate
Message-ID: <201711151309.vAFD9hrZ001967@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c820b43fc053689eac0a60cd732347c8eb30ad5d
Commit:        c820b43fc053689eac0a60cd732347c8eb30ad5d
Parent:        eab9097b46b10ce61344c02934fe5c44b9f8c7c7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 14 11:35:50 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 15 12:11:33 2017 +0100

activate_lvs: deactivate on uniterate

When activation of LVs fails prior pvmove start, try to deactivate
already activated LVs.

TODO: possibly remember which LVs where already activate and only those
take down - devices which are already in-use will stay active.
---
 WHATS_NEW             |    1 +
 lib/locking/locking.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d3670bc..728cc4f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Deactivate activated LVs on error path when pvmove activation fails.
   Add "io" to log/debug_classes for logging low-level I/O.
   Eliminate redundant nested VG metadata in VG struct.
   Avoid importing persistent filter in vgscan/pvscan/vgrename.
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index bf39b4a..067cd69 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -475,7 +475,7 @@ int activate_lvs(struct cmd_context *cmd, struct dm_list *lvs, unsigned exclusiv
 			log_error("Failed to activate %s", lvl->lv->name);
 			dm_list_uniterate(lvh, lvs, &lvl->list) {
 				lvl = dm_list_item(lvh, struct lv_list);
-				if (!activate_lv(cmd, lvl->lv))
+				if (!deactivate_lv(cmd, lvl->lv))
 					stack;
 			}
 			return 0;


