From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 12 Apr 2010 17:21:43 +0200
Subject: [PATCH 15/22] Replicator: activate checks for missing vgs
In-Reply-To: <cover.1271085009.git.zkabelac@redhat.com>
References: <cover.1271085009.git.zkabelac@redhat.com>
Message-ID: <63d547b05e12868836f3c54eaf20ad01bce1552e.1271085009.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Activation needs to have all remote VGs locked to pass for replicator.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/activate.c |   22 ++++++++++++++++++----
 1 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 1844cea..4aabc38 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -865,6 +865,9 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		goto out;
 	}
 
+	if (!lv_read_replicator_vgs(lv))
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
+		lv_release_replicator_vgs(lv);
 		vg_release(lv->vg);
-
+	}
 	return r;
 }
 
@@ -1025,6 +1029,9 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
 			goto_out;
 	}
 
+	if (!lv_read_replicator_vgs(lv))
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
+		lv_release_replicator_vgs(lv);
 		vg_release(lv->vg);
+	}
 
 	return r;
 }
@@ -1118,6 +1127,9 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 		goto out;
 	}
 
+	if (!lv_read_replicator_vgs(lv))
+		goto_out;
+
 	lv_calculate_readahead(lv, NULL);
 
 	if (exclusive)
@@ -1133,8 +1145,10 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 		stack;
 
 out:
-	if (lv)
+	if (lv) {
+		lv_release_replicator_vgs(lv);
 		vg_release(lv->vg);
+	}
 
 	return r;
 }
-- 
1.7.0.1


