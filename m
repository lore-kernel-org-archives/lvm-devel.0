From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 30 Apr 2019 07:30:43 -0400
Subject: stable-2.02 - thin: fix maintenance of _pmspare
Message-ID: <201904301130.x3UBUhmv020442@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f38cfd09c4a2b2ea76662264f3f99abff24b3ca0
Commit:        f38cfd09c4a2b2ea76662264f3f99abff24b3ca0
Parent:        515867bbad4565b788460b1fc8cfe91acd5ade1e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 3 13:02:50 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 30 12:02:49 2019 +0200

thin: fix maintenance of _pmspare

When metadata grows lvm2 may need to extend also _pmspare volume.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7949a4a..89ddd41 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.185 - 
 ==================================
+  Fix missing growth of _pmsmare volume when extending _tmeta volume.
   Automatically grow thin metadata, when thin data gets too big.
   Add support for vgsplit with cached devices.
   Fix signal delivery checking race in libdaemon (lvmetad).
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2ea8eb4..68ad3c3 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5400,6 +5400,10 @@ static int _lvresize_volume(struct logical_volume *lv,
 					display_lvname(lv),
 					display_size(cmd, (uint64_t) old_extents * vg->extent_size), old_extents,
 					display_size(cmd, (uint64_t) lv->le_count * vg->extent_size), lv->le_count);
+
+		/* Resizing metadata and PV list is not specified -> maintain size of _pmspare volume */
+		if ((&vg->pvs == pvh) && lv_is_pool_metadata(lv))
+			(void) handle_pool_metadata_spare(vg, 0, pvh, 1);
 	}
 
 	return 1;


