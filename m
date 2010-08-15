From: Jonathan Brassow <jbrassow@redhat.com>
Date: Sun, 15 Aug 2010 17:29:25 -0500
Subject: [PATCH 2 of 3] Handle failures of mirror devices while under snapshot origin (bug 613829)
Message-ID: <1281911365.30206.6.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The code that was evaluating the mirror status line for failure
was not taking into account that a mirror might be under a
snapshot origin.  This patch causes it to look at <lv>-real
if necessary.

Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/lib/activate/dev_manager.c
===================================================================
--- LVM2.orig/lib/activate/dev_manager.c
+++ LVM2/lib/activate/dev_manager.c
@@ -558,10 +558,11 @@ int dev_manager_transient(struct dev_man
 	char *type = NULL;
 	char *params = NULL;
 	char *dlid = NULL;
+	char *suffix = lv_is_origin(lv) ? "real" : NULL;
 	const struct dm_list *segh = &lv->segments;
 	struct lv_segment *seg = NULL;
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, NULL)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, suffix)))
 		return_0;
 
 	if (!(dmt = _setup_task(0, dlid, NULL, DM_DEVICE_STATUS, 0, 0)))



