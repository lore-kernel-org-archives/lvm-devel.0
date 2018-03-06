From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 6 Mar 2018 09:46:26 -0500
Subject: master - lvremove: ensure no subLV is active
Message-ID: <201803061446.w26EkQPs026944@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f92b6f99305a31fe0e12b836942ec429c4828869
Commit:        f92b6f99305a31fe0e12b836942ec429c4828869
Parent:        73e93ef5e5e42018c701149a51db17e247dbb9a6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 2 22:07:14 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 6 15:42:07 2018 +0100

lvremove: ensure no subLV is active

Since component activation is going to be enabled, enusure,
no subLV is active when we deactivate LV.
---
 lib/metadata/lv_manip.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ff82b2d..a1fc0ff 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2018 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -6086,12 +6086,9 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	/* Used cache pool, COW or historical LV cannot be activated */
 	if (!lv_is_used_cache_pool(lv) &&
 	    !lv_is_cow(lv) && !lv_is_historical(lv) &&
-	    !deactivate_lv(cmd, lv)) {
+	    !deactivate_lv_with_sub_lv(lv))
 		/* FIXME Review and fix the snapshot error paths! */
-		log_error("Unable to deactivate logical volume %s.",
-			  display_lvname(lv));
-		return 0;
-	}
+		return_0;
 
 	if (!archive(vg))
 		return 0;


