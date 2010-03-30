From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 30 Mar 2010 17:17:16 +0200
Subject: [PATCH 15/22] Replicator: extend activate with rsite resolving
In-Reply-To: <cover.1269961680.git.zkabelac@redhat.com>
References: <cover.1269961680.git.zkabelac@redhat.com>
Message-ID: <8784465d4b72050ac9145ac677e479364a3ee06e.1269961680.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Activation code needs to have all remote lv pointers resolved.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/activate.c |   22 ++++++++++++++++++----
 1 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 1844cea..8224be0 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -865,6 +865,9 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		goto out;
 	}
 
+	if (!lv_replicator_sites_read(lv))
+		goto_out;
+
 	lv_calculate_readahead(lv, NULL);
 
 	/* If VG was precommitted, preload devices for the LV */
@@ -894,9 +897,10 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 out:
 	if (lv_pre)
 		vg_release(lv_pre->vg);
-	if (lv)
+	if (lv) {
+		lv_replicator_sites_release(lv);
 		vg_release(lv->vg);
-
+	}
 	return r;
 }
 
@@ -1025,6 +1029,9 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
 			goto_out;
 	}
 
+	if (!lv_replicator_sites_read(lv))
+		goto_out;
+
 	lv_calculate_readahead(lv, NULL);
 
 	if (!monitor_dev_for_events(cmd, lv, 0))
@@ -1038,8 +1045,10 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
 	if (!lv_info(cmd, lv, &info, 1, 0) || info.exists)
 		r = 0;
 out:
-	if (lv)
+	if (lv) {
+		lv_replicator_sites_release(lv);
 		vg_release(lv->vg);
+	}
 
 	return r;
 }
@@ -1118,6 +1127,9 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 		goto out;
 	}
 
+	if (!lv_replicator_sites_read(lv))
+		goto_out;
+
 	lv_calculate_readahead(lv, NULL);
 
 	if (exclusive)
@@ -1133,8 +1145,10 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 		stack;
 
 out:
-	if (lv)
+	if (lv) {
+		lv_replicator_sites_release(lv);
 		vg_release(lv->vg);
+	}
 
 	return r;
 }
-- 
1.7.0.1


