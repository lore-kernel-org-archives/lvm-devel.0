From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 1 Dec 2017 06:20:21 -0500
Subject: master - pvmove: add missing segment merging
Message-ID: <201712011120.vB1BKL7C029408@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c489dd2e1764216de07be80d36b1025fb4f6fc85
Commit:        c489dd2e1764216de07be80d36b1025fb4f6fc85
Parent:        fbd8b456dbc963bbc306e5b3c643d0f67d3a2d6c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 29 22:19:46 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 1 12:19:09 2017 +0100

pvmove: add missing segment merging

When pvmove is finished and metadata are updated, the code missed
to merge possible mergable segments - so add explicit merging
call after pvmoved volumes are unlocked.

This avoids weird results where i.e. lvs could have been reporting
non-matching segments as lvs upon metadata read is doing silent segment
merging while dm table left after pvmove was still preserving
non-merged segments.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 32ed3c9..093fc95 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Merge segments when pvmove is finished.
   Remove label_verify that has never been used.
   Ensure very large numbers used as arguments are not casted to lower values. 
   Enhance reading and validation of options stripes and stripes_size.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d4a4b8b..fb152ac 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6637,6 +6637,8 @@ int remove_layers_for_segments_all(struct cmd_context *cmd,
 	dm_list_iterate_items(lvl, lvs_changed) {
 		/* FIXME Assumes only one pvmove at a time! */
 		lvl->lv->status &= ~LOCKED;
+		if (!lv_merge_segments(lvl->lv))
+			return_0;
 	}
 
 	return 1;


