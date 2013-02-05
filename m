From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  5 Feb 2013 13:47:54 +0000 (UTC)
Subject: master - thin: properly unmark volume after detach
Message-ID: <20130205134754.7B68DA0C2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c984d8fbab73face6a137cd72c114e3c2edb0448
Commit:        c984d8fbab73face6a137cd72c114e3c2edb0448
Parent:        416eb4b9b352c65e019cbd0a11265050b7360c63
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 5 11:07:09 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 5 14:40:37 2013 +0100

thin: properly unmark volume after detach

When the volume is detached form thin pool,
unmask THIN_VOLUME flag and reset related pointers.
---
 WHATS_NEW                 |    1 +
 lib/metadata/thin_manip.c |    6 +++++-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b6c1785..c08f2a5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix missing cleanup of flags when the LV is detached from pool.
   Fix check for some forbidden discards conversion of thin pools.
   Add pool_is_active() to check for any pool related active LV.
   Report blank field if the LV doesn't have an origin instead of 0.
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 51f3d16..6ec97d4 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2011-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -136,6 +136,10 @@ int detach_pool_lv(struct lv_segment *seg)
 		sl->seg->origin = NULL;
 	}
 
+	seg->lv->status &= ~THIN_VOLUME;
+	seg->pool_lv = NULL;
+	seg->origin = NULL;
+
 	return 1;
 }
 


