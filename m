From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 26 Mar 2010 18:19:11 -0400
Subject: [PATCH] do not allow --ignoremonitoring if on clustered VG
Message-ID: <20100326221911.GA23734@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

clvmd does not propagate DMEVENTD_MONITOR_IGNORE.

Update get_activation_monitoring_mode() to check if the VG that the
LV is being activated in is clustered.  If so, skip it.

Any get_activation_monitoring_mode() error will cause the associated LV
(or VG) to be skipped during activation.  Both vgchange_single() and
lvchange_single(), which call get_activation_monitoring_mode(), are
called by their respective process_each_..() method.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 tools/lvchange.c |    2 +-
 tools/lvcreate.c |    3 ++-
 tools/toollib.c  |   11 +++++++++++
 tools/toollib.h  |    1 +
 tools/vgchange.c |    2 +-
 5 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 534c993..9929740 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -575,7 +575,7 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return ECMD_FAILED;
 	}
 
-	if (!get_activation_monitoring_mode(cmd, &dmeventd_mode))
+	if (!get_activation_monitoring_mode(cmd, lv->vg, &dmeventd_mode))
 		return ECMD_FAILED;
 
 	init_dmeventd_monitor(dmeventd_mode);
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 10b5aa5..d394cd8 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -482,7 +482,8 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		return 0;
 	}
 
-	if (!get_activation_monitoring_mode(cmd, &lp->activation_monitoring))
+	if (!get_activation_monitoring_mode(cmd, NULL,
+					    &lp->activation_monitoring))
 		return_0;
 
 	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
diff --git a/tools/toollib.c b/tools/toollib.c
index b1528e2..52ea4a6 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1424,6 +1424,7 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 }
 
 int get_activation_monitoring_mode(struct cmd_context *cmd,
+				   struct volume_group *vg,
 				   int *monitoring_mode)
 {
 	*monitoring_mode = DEFAULT_DMEVENTD_MONITOR;
@@ -1441,6 +1442,16 @@ int get_activation_monitoring_mode(struct cmd_context *cmd,
 		 !find_config_tree_bool(cmd, "activation/monitoring",
 					DEFAULT_DMEVENTD_MONITOR))
 		*monitoring_mode = DMEVENTD_MONITOR_IGNORE;
+
+	if (vg && vg_is_clustered(vg) &&
+	    *monitoring_mode == DMEVENTD_MONITOR_IGNORE) {
+		log_error("%s is incompatible with clustered Volume Group "
+			  "\"%s\": Skipping.",
+			  (arg_count(cmd, ignoremonitoring_ARG) ?
+			   "--ignoremonitoring" : "activation/monitoring=0"),
+			  vg->name);
+		return 0;
+	}
 	
 	return 1;
 }
diff --git a/tools/toollib.h b/tools/toollib.h
index 987814e..0ea7eba 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -113,6 +113,7 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 			     struct pvcreate_params *pp);
 
 int get_activation_monitoring_mode(struct cmd_context *cmd,
+				   struct volume_group *vg,
 				   int *monitoring_mode);
 
 #endif
diff --git a/tools/vgchange.c b/tools/vgchange.c
index e013bde..81c95d1 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -529,7 +529,7 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 		return ECMD_FAILED;
 	}
 
-	if (!get_activation_monitoring_mode(cmd, &dmeventd_mode))
+	if (!get_activation_monitoring_mode(cmd, vg, &dmeventd_mode))
 		return ECMD_FAILED;
 
 	init_dmeventd_monitor(dmeventd_mode);


