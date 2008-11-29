From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sat, 29 Nov 2008 16:02:33 -0500
Subject: [PATCH 4/4] Update vgcreate and vgextend to allow uninitialized devices as input.
In-Reply-To: <1227992553-4381-3-git-send-email-dwysocha@redhat.com>
References: <1227992553-4381-1-git-send-email-dwysocha@redhat.com>
	<1227992553-4381-2-git-send-email-dwysocha@redhat.com>
	<1227992553-4381-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1227992553-4381-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Note that this changes the behavior of vgcreate and vgextend when non-PV
devices are given.  Previously this would result in vgextend or vgcreate
printing an error message and exiting.  Now these tools will prompt the
user.

With this update, the user may opt to skip pvcreate, provided the default
values of pvcreate are adequate.  If the user wants some non-default value
in the PV (e.g. 0 metadatacopies, etc), pvcreate must be used prior to
vgcreate/vgextend.

Update man pages to clarify the new behavior.

Modify pvcreate_single() to first check whether the VG_ORPHANS lock is
held before trying to obtain it.  This is necessary for the vgexten
code path, which must obtain VG_ORPHANS before obtaining the appropriate
VG lock, and befroe calling vg_extend().  The other paths calling
pvcreate_single() are pvcreate() and vgcreate(), and neither of these
paths hold VG_ORPHANS.  Without this modification vgextend() will hang
trying to obtain VG_ORPHANS which it already holds.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |   32 ++++++++++++++++++++++++++++----
 man/vgcreate.8.in       |   15 +++++++++------
 man/vgextend.8.in       |    6 ++++++
 4 files changed, 44 insertions(+), 10 deletions(-)

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
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 4b231d3..4e375f5 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -422,9 +422,22 @@ int vg_extend(struct volume_group *vg, int pv_count, char **pv_names)
 	/* attach each pv */
 	for (i = 0; i < pv_count; i++) {
 		if (!(pv = pv_by_path(vg->fid->fmt->cmd, pv_names[i]))) {
-			log_error("%s not identified as an existing "
-				  "physical volume", pv_names[i]);
-			goto bad;
+			if (yes_no_prompt("%s not identified as an existing "
+					  "physical volume.\nInitialize "
+					  "device and add to volume "
+					  "group %s? [y/n]: ", pv_names[i],
+					  vg->name) == 'n') {
+				goto bad;
+			} else {
+				pv = pvcreate_single(vg->cmd, pv_names[i],
+						     NULL);
+				if (!pv) {
+					log_error("Failed to setup physical "
+						  "volume \"%s\"",
+						  pv_names[i]);
+					goto bad;
+				}
+			}
 		}
 		
 		if (!add_pv_to_vg(vg, pv_names[i], pv))
@@ -990,6 +1003,16 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	return 1;
 }
 
+/*
+ * pvcreate_single() - initialize a device with PV label and metadata
+ *
+ * Locking: Ok (but not required) for caller to hold VG_ORPHAN lock
+ * before calling
+ *
+ * Parameters:
+ * - pv_name: device path to initialize
+ * - handle: options to pass to pv_create; NULL indicates use defaults
+ */
 pv_t *pvcreate_single(struct cmd_context *cmd, const char *pv_name,
 		      void *handle)
 {
@@ -1025,7 +1048,8 @@ pv_t *pvcreate_single(struct cmd_context *cmd, const char *pv_name,
 		}
 	}
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+	if (!vgname_is_locked(VG_ORPHANS) &&
+	    (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE))) {
 		log_error("Can't get lock for orphan PVs");
 		return NULL;
 	}
diff --git a/man/vgcreate.8.in b/man/vgcreate.8.in
index a53197e..0e8baa2 100644
--- a/man/vgcreate.8.in
+++ b/man/vgcreate.8.in
@@ -21,16 +21,19 @@ vgcreate \- create a volume group
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
+\fBpvcreate (8)\fP, a prompt will be given to confirm initialization of
+the device.  If confirmed, the device will be initialized with the same
+default values used with \fBpvcreate\fP.  If non-default 
+\fPpvcreate\fP values are are desired, \fBpvcreate\fP should be explicitly
+called prior to calling \fBvgcreate\fP.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
diff --git a/man/vgextend.8.in b/man/vgextend.8.in
index 682cc5a..1fee769 100644
--- a/man/vgextend.8.in
+++ b/man/vgextend.8.in
@@ -11,6 +11,12 @@ VolumeGroupName PhysicalDevicePath [PhysicalDevicePath...]
 vgextend allows you to add one or more initialized physical volumes ( see
 .B pvcreate(8)
 ) to an existing volume group to extend it in size.
+If \fIPhysicalDevicePath\fP was not previously configured for LVM with
+\fBpvcreate (8)\fP, a prompt will be given to confirm initialization of
+the device.  If confirmed, the device will be initialized with the same
+default values used with \fBpvcreate\fP.  If non-default 
+\fPpvcreate\fP values are are desired, \fBpvcreate\fP should be explicitly
+called prior to calling \fBvgextend\fP.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .SH Examples
-- 
1.5.5.1


