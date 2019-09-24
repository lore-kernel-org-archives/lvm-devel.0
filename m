From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 24 Sep 2019 04:52:31 -0400
Subject: stable-2.02 - lvmetad: Fix function prototype when not configured
Message-ID: <201909240852.x8O8qVIc006869@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=92f1c888e0881f3defb4d0220d89f6225be70f7d
Commit:        92f1c888e0881f3defb4d0220d89f6225be70f7d
Parent:        a57b92dec396ac79c57e02e54c04e205aa85f084
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Sep 24 10:34:44 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Sep 24 10:34:44 2019 +0200

lvmetad: Fix function prototype when not configured

Fixes: 6b129308
---
 lib/cache/lvmetad.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 55ce16a..ebc3365 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -196,7 +196,7 @@ static inline int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *
 			  struct dm_list *found_vgnames,
 			  struct dm_list *changed_vgnames) {return 0;}
 
-static inline int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait) {return 0;}
+static inline int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait, struct dm_list *found_vgnames) {return 0;}
 
 static inline int lvmetad_vg_clear_outdated_pvs(struct volume_group *vg) {return 0;}
 static inline void lvmetad_validate_global_cache(struct cmd_context *cmd, int force) {}


