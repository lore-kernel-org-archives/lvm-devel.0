From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 17 Mar 2010 14:47:07 +0100
Subject: [PATCH 14/25] Replicator: extend activate with rsite resolving
In-Reply-To: <cover.1268833246.git.zkabelac@redhat.com>
References: <cover.1268833246.git.zkabelac@redhat.com>
Message-ID: <bf0e9ee80949ea706c039a7f13e134f3fe433e3a.1268833246.git.zkabelac@redhat.com>
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
index eb94ac0..6c28c4f 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -854,6 +854,9 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		goto out;
 	}
 
+	if (!lv_replicator_sites_read(lv))
+		goto_out;
+
 	lv_calculate_readahead(lv, NULL);
 
 	/* If VG was precommitted, preload devices for the LV */
@@ -883,9 +886,10 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
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
 
@@ -1014,6 +1018,9 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
 			goto_out;
 	}
 
+	if (!lv_replicator_sites_read(lv))
+		goto_out;
+
 	lv_calculate_readahead(lv, NULL);
 
 	if (!monitor_dev_for_events(cmd, lv, 0))
@@ -1027,8 +1034,10 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
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
@@ -1107,6 +1116,9 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 		goto out;
 	}
 
+	if (!lv_replicator_sites_read(lv))
+		goto_out;
+
 	lv_calculate_readahead(lv, NULL);
 
 	if (exclusive)
@@ -1122,8 +1134,10 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
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


