From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  4 Oct 2009 19:11:41 -0400
Subject: [PATCH 04/10] Allow calling fill_default_pvcreate_params from tools.
In-Reply-To: <1254697907-16448-4-git-send-email-dwysocha@redhat.com>
References: <1254697907-16448-1-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-2-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-3-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1254697907-16448-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We need defaults for pvcreate_params at a higher level - this will
allow us to use a common function from the tools to take defaults,
then fill in any non-defaults from the commandline.

Future patches will refactor vgcreate/vgextend to call this function
if one or more pvcreate parameters are given on the commandline.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |    2 +-
 liblvm/lvm_vg.c                  |   13 ++++---------
 3 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index ebaea92..b67afd0 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -371,6 +371,7 @@ struct pvcreate_params {
 struct physical_volume *pvcreate_single(struct cmd_context *cmd,
 					const char *pv_name,
 					struct pvcreate_params *pp);
+void fill_default_pvcreate_params(struct pvcreate_params *pp);
 
 /*
 * Utility functions
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5f65d26..341128d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1272,7 +1272,7 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	return 1;
 }
 
-static void fill_default_pvcreate_params(struct pvcreate_params *pp)
+void fill_default_pvcreate_params(struct pvcreate_params *pp)
 {
 	memset(pp, 0, sizeof(*pp));
 	pp->zero = 0;
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 0c097c0..4b4d7f6 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -41,6 +41,8 @@ vg_t lvm_vg_create(lvm_t libh, const char *vg_name)
 
 int lvm_vg_extend(vg_t vg, const char *device)
 {
+	struct pvcreate_params pp;
+
 	if (vg_read_error(vg))
 		return -1;
 
@@ -52,15 +54,8 @@ int lvm_vg_extend(vg_t vg, const char *device)
 		return -1;
 	}
 
-	/* If device not initialized, pvcreate it */
-	if (!pv_by_path(vg->cmd, device) &&
-	   (!pvcreate_single(vg->cmd, device, NULL))) {
-		log_error("Unable to initialize device for LVM use");
-		unlock_vg(vg->cmd, VG_ORPHANS);
-		return -1;
-	}
-
-	if (!vg_extend(vg, 1, (char **) &device, NULL)) {
+	fill_default_pvcreate_params(&pp);
+	if (!vg_extend(vg, 1, (char **) &device, &pp)) {
 		unlock_vg(vg->cmd, VG_ORPHANS);
 		return -1;
 	}
-- 
1.6.0.6


