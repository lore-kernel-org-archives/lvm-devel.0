From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Jul 2009 00:05:50 -0400
Subject: [PATCH 5/8] Update vgcreate and vgextend to allow uninitialized devices as input.
In-Reply-To: <1248235553-13519-5-git-send-email-dwysocha@redhat.com>
References: <1248235553-13519-1-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-2-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-3-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-4-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-5-git-send-email-dwysocha@redhat.com>
Message-ID: <1248235553-13519-6-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Note that this changes the behavior of vgcreate and vgextend when non-PV
devices are given.  Previously this would result in vgextend or vgcreate
printing an error message and exiting.  Now these tools will implicitly
pvcreate on any devices given on the commandline that are not already
PVs.  All devices given on the commandline are first checked if they are
an existing PV before attempting to initialize, so there should be little/no
risk with this change.

Add pvcreate_devices() helper function that loops through a set of device
names and runs pvcreate_single on each device if it is not already a PV.
Note - pvcreate_devices calls pvcreate_single.  Currently the ORPHAN lock
must be held prior to calling pvcreate_single.  In the future, pvcreate_single
should be further refactored but for now we leave this as is.

With this update, the user may opt to skip pvcreate, provided the default
values of pvcreate are adequate.  If the user wants some non-default value
in the PV (e.g. 0 metadatacopies, etc), pvcreate must be used prior to
vgcreate/vgextend.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   40 +++++++++++++++++++++++++++++++++-------
 tools/pvcreate.c        |   10 +++++++++-
 2 files changed, 42 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 01fa4d8..ec265a0 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -67,6 +67,9 @@ static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
 const char _really_init[] =
     "Really INITIALIZE physical volume \"%s\" of volume group \"%s\" [y/n]? ";
 
+static int pvcreate_devices(struct cmd_context *cmd,
+			    int pv_count, char **pv_names);
+
 unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignment)
 {
 	if (pv->pe_align)
@@ -517,6 +520,9 @@ int vg_extend(struct volume_group *vg, int pv_count, char **pv_names)
 		return 0;
 	}
 
+	if (!pvcreate_devices(cmd, pv_count, pv_names))
+		return 0;
+
 	/* attach each pv */
 	for (i = 0; i < pv_count; i++) {
 		if (!(pv = pv_by_path(vg->fid->fmt->cmd, pv_names[i]))) {
@@ -1097,6 +1103,30 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	return 1;
 }
 
+/*
+ * Run pvcreate on a set of devices if they are not currently initialized.
+ */
+static int pvcreate_devices(struct cmd_context *cmd,
+			    int pv_count, char **pv_names)
+{
+	int i;
+	pv_t *pv;
+
+	for (i = 0; i < pv_count; i++) {
+		if (!(pv = pv_by_path(cmd, pv_names[i]))) {
+			log_verbose("Running pvcreate on %s", pv_names[i]);
+			if (!pvcreate_single(cmd, pv_names[i], NULL)) {
+				log_error("Failed to setup physical "
+					  "volume \"%s\"",
+					  pv_names[i]);
+				return 0;
+			}
+		}
+	}
+
+	return 1;
+}
+
 static void fill_default_pvcreate_params(struct pvcreate_params *pp)
 {
 	memset(pp, 0, sizeof(*pp));
@@ -1118,6 +1148,9 @@ static void fill_default_pvcreate_params(struct pvcreate_params *pp)
 /*
  * pvcreate_single() - initialize a device with PV label and metadata
  *
+ * NOTE: Assumes ORPHAN_LOCK held by caller.
+ * FIXME: Refactor to do simple pv_create + 'set' calls
+ *
  * Parameters:
  * - pv_name: device path to initialize
  * - handle: options to pass to pv_create; NULL indicates use defaults
@@ -1150,11 +1183,6 @@ pv_t * pvcreate_single(struct cmd_context *cmd, const char *pv_name,
 		}
 	}
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-		log_error("Can't get lock for orphan PVs");
-		return NULL;
-	}
-
 	if (!pvcreate_check(cmd, pv_name, pp))
 		goto error;
 
@@ -1211,11 +1239,9 @@ pv_t * pvcreate_single(struct cmd_context *cmd, const char *pv_name,
 
 	log_print("Physical volume \"%s\" successfully created", pv_name);
 
-	unlock_vg(cmd, VG_ORPHANS);
 	return pv;
 
       error:
-	unlock_vg(cmd, VG_ORPHANS);
 	return NULL;
 }
 
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index e21fe94..11c226e 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -170,13 +170,21 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+		log_error("Can't get lock for orphan PVs");
+		return ECMD_FAILED;
+	}
+
 	for (i = 0; i < argc; i++) {
 		if (!pvcreate_single(cmd, argv[i], &pp))
 			ret = ECMD_FAILED;
 
-		if (sigint_caught())
+		if (sigint_caught()) {
+			unlock_vg(cmd, VG_ORPHANS);
 			return ret;
+		}
 	}
 
+	unlock_vg(cmd, VG_ORPHANS);
 	return ret;
 }
-- 
1.6.0.6


