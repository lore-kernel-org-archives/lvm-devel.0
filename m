From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Sep 2014 23:14:56 +0000 (UTC)
Subject: master - memlock: drop uneeded lock
Message-ID: <20140918231456.59F1B606D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d8b775f4eb871e771c9f18dcd9f6b28509e7e52a
Commit:        d8b775f4eb871e771c9f18dcd9f6b28509e7e52a
Parent:        b0bd8ce4086531f4f83ce417ddb988d8b4e0907a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 19 01:09:36 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 19 01:13:49 2014 +0200

memlock: drop uneeded lock

Avoid doing buffered operation within memory lock.
---
 lib/metadata/lv_manip.c   |    4 ++++
 lib/metadata/thin_manip.c |    4 ++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 58bc79b..2e683b9 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -29,6 +29,7 @@
 #include "defaults.h"
 #include "lvm-exec.h"
 #include "lvm-signal.h"
+#include "memlock.h"
 
 typedef enum {
 	PREFERRED,
@@ -6877,6 +6878,9 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		       thin_name, lp->pvh, lp->alloc, lp->approx_alloc))
 		return_NULL;
 
+	/* Unlock memory if possible */
+	memlock_unlock(vg->cmd);
+
 	if (seg_is_cache_pool(lp)) {
 		first_seg(lv)->chunk_size = lp->chunk_size;
 		first_seg(lv)->feature_flags = lp->feature_flags;
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 61e9c6e..b781e02 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -15,6 +15,7 @@
 #include "lib.h"
 #include "activate.h"
 #include "locking.h"
+#include "memlock.h"
 #include "metadata.h"
 #include "segtype.h"
 #include "defaults.h"
@@ -370,6 +371,9 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 				return_0;
 			}
 			init_dmeventd_monitor(monitored);
+
+			/* Unlock memory if possible */
+			memlock_unlock(lv->vg->cmd);
 		}
 		/*
 		 * Resume active pool to send thin messages.


