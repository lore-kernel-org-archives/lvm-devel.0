From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun, 30 Nov 2008 14:11:13 -0500
Subject: [PATCH] Update vgcreate and vgextend to allow uninitialized devices as input.
In-Reply-To: <1228055977.3315.21.camel@localhost.localdomain>
References: <1228055977.3315.21.camel@localhost.localdomain>
Message-ID: <1228072273-8119-1-git-send-email-dwysocha@redhat.com>
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

With this update, the user may opt to skip pvcreate, provided the default
values of pvcreate are adequate.  If the user wants some non-default value
in the PV (e.g. 0 metadatacopies, etc), pvcreate must be used prior to
vgcreate/vgextend.

Update man pages to clarify the new behavior.

Add pvcreate_devices() helper function inside toollib which loops through
a set of device names and runs pvcreate on each devices if it is not already
a PV.
---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |    7 +++++++
 lib/metadata/metadata.h          |    1 -
 man/vgcreate.8.in                |   14 ++++++++------
 man/vgextend.8.in                |    5 +++++
 tools/toollib.c                  |   23 +++++++++++++++++++++++
 tools/toollib.h                  |    2 ++
 tools/vgcreate.c                 |    6 ++++++
 tools/vgextend.c                 |    6 ++++++
 10 files changed, 59 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 459533a..03ec238 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.44 - 
 ====================================
+  Update vgcreate and vgextend to allow uninitialized devices as input.
   Don't skip updating pvid hash when lvmcache_info struct got swapped.
   Add tinfo to termcap search path for pld-linux.
   Fix startup race in clvmd.
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index c77ebdd..71dfe36 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -588,6 +588,7 @@ uint32_t pv_pe_size(const pv_t *pv);
 uint64_t pv_pe_start(const pv_t *pv);
 uint32_t pv_pe_count(const pv_t *pv);
 uint32_t pv_pe_alloc_count(const pv_t *pv);
+pv_t *pv_by_path(struct cmd_context *cmd, const char *pv_name);
 
 int vg_missing_pv_count(const vg_t *vg);
 uint32_t vg_status(const vg_t *vg);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 4b231d3..8afa322 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -990,6 +990,13 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	return 1;
 }
 
+/*
+ * pvcreate_single() - initialize a device with PV label and metadata
+ *
+ * Parameters:
+ * - pv_name: device path to initialize
+ * - handle: options to pass to pv_create; NULL indicates use defaults
+ */
 pv_t *pvcreate_single(struct cmd_context *cmd, const char *pv_name,
 		      void *handle)
 {
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 3d9fd8d..7ce2c62 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -343,7 +343,6 @@ struct id pv_id(const pv_t *pv);
 const struct format_type *pv_format_type(const pv_t *pv);
 struct id pv_vgid(const pv_t *pv);
 
-pv_t *pv_by_path(struct cmd_context *cmd, const char *pv_name);
 int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 		 struct physical_volume *pv);
 
diff --git a/man/vgcreate.8.in b/man/vgcreate.8.in
index a53197e..54276dd 100644
--- a/man/vgcreate.8.in
+++ b/man/vgcreate.8.in
@@ -21,16 +21,18 @@ vgcreate \- create a volume group
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
-.I VolumeGroupName PhysicalVolumePath
-.RI [ PhysicalVolumePath ...]
+.I VolumeGroupName PhysicalDevicePath
+.RI [ PhysicalDevicePath ...]
 .SH DESCRIPTION
 .B vgcreate
 creates a new volume group called
 .I VolumeGroupName
-using the block special device
-.IR PhysicalVolumePath
-previously configured for LVM with
-.BR pvcreate (8).
+using the block special device \fIPhysicalDevicePath\fP.
+If \fIPhysicalDevicePath\fP was not previously configured for LVM with
+\fBpvcreate (8)\fP, the device will be initialized with the same
+default values used with \fBpvcreate\fP.  If non-default 
+\fPpvcreate\fP values are are desired, \fBpvcreate\fP should be explicitly
+called prior to calling \fBvgcreate\fP.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
diff --git a/man/vgextend.8.in b/man/vgextend.8.in
index 682cc5a..3ba44a7 100644
--- a/man/vgextend.8.in
+++ b/man/vgextend.8.in
@@ -11,6 +11,11 @@ VolumeGroupName PhysicalDevicePath [PhysicalDevicePath...]
 vgextend allows you to add one or more initialized physical volumes ( see
 .B pvcreate(8)
 ) to an existing volume group to extend it in size.
+If \fIPhysicalDevicePath\fP was not previously configured for LVM with
+\fBpvcreate (8)\fP, the device will be initialized with the same
+default values used with \fBpvcreate\fP.  If non-default 
+\fPpvcreate\fP values are are desired, \fBpvcreate\fP should be explicitly
+called prior to calling \fBvgcreate\fP.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .SH Examples
diff --git a/tools/toollib.c b/tools/toollib.c
index ef4ee0e..2f0713e 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1288,3 +1288,26 @@ int fill_vg_create_params(struct cmd_context *cmd,
 
 	return 0;
 }
+
+/*
+ * Run pvcreate on a set of devices if they are not currently initialized.
+ */
+int pvcreate_devices(struct cmd_context *cmd, int pv_count, char **pv_names)
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
diff --git a/tools/toollib.h b/tools/toollib.h
index f002d60..72d13a3 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -100,4 +100,6 @@ int is_reserved_lvname(const char *name);
 int fill_vg_create_params(struct cmd_context *cmd,
 			  char *vg_name, struct vgcreate_params *vp_new,
 			  struct vgcreate_params *vp_def);
+int pvcreate_devices(struct cmd_context *cmd, int pv_count, char **pv_names);
+
 #endif
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 62c957a..d579ea9 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -46,6 +46,12 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	if (validate_vg_create_params(cmd, &vp_new))
 	    return EINVALID_CMD_LINE;
 
+	/*
+	 * Check whether any devices need initialized
+	 */
+	if (!pvcreate_devices(cmd, argc - 1, argv + 1))
+		return ECMD_FAILED;
+
 	/* Create the new VG */
 	if (!(vg = vg_create(cmd, vp_new.vg_name, vp_new.extent_size,
 			     vp_new.max_pv, vp_new.max_lv, vp_new.alloc,
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 089c44e..154fbf6 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -35,6 +35,12 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	argc--;
 	argv++;
 
+	/*
+	 * Check whether any devices need initialized
+	 */
+	if (!pvcreate_devices(cmd, argc, argv))
+		return ECMD_FAILED;
+
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 		log_error("Can't get lock for orphan PVs");
 		return ECMD_FAILED;
-- 
1.5.5.1


