From: dongsu.park@profitbricks.com <dongsu.park@profitbricks.com>
Date: Mon, 16 Jul 2012 23:18:39 +0200
Subject: [RFC PATCH 3/3] a new config option devices/md_detect_metadata_legacy
In-Reply-To: <1342473519-2853-1-git-send-email-dongsu.park@profitbricks.com>
References: <1342473519-2853-1-git-send-email-dongsu.park@profitbricks.com>
Message-ID: <1342473519-2853-4-git-send-email-dongsu.park@profitbricks.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Dongsu Park <dongsu.park@profitbricks.com>

This commit introduces a new config option md_detect_metadata_legacy
under devices section in lvm.conf, to be able to switch on or off
detection of legacy metadata versions, i.e. 0.9 or 1.0.

By default, LVM2 will try to detect if each device is MD device,
reading MD checksums from different offsets for each MD versions,
i.e. 1.2, 1.1, 1.0, 0.9. Legacy versions mean 1.0 and 0.9.
For both of them, LVM2 has to seek to the end of every block device.
If that causes performance degradation, this option can be disabled,
so that the checksum can only be searched for v1.2 and v1.1 from
the beginning of each device.
(1 enables (by default); 0 disables)

Signed-off-by: Dongsu Park <dongsu.park@profitbricks.com>
---
 doc/example.conf.in        |   10 ++++++++++
 lib/commands/toolcontext.c |    5 +++++
 lib/config/defaults.h      |    1 +
 lib/device/dev-md.c        |    6 +++++-
 lib/misc/lvm-globals.c     |   11 +++++++++++
 man/lvm.conf.5.in          |    8 ++++++++
 6 files changed, 40 insertions(+), 1 deletion(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index a085014..da1adbc 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -121,6 +121,16 @@ devices {
     # 1 enables; 0 disables.
     md_chunk_alignment = 1
 
+    # By default, LVM2 will try to detect if each device is MD device,
+    # reading MD checksums from different offsets for each MD versions,
+    # i.e. 1.2, 1.1, 1.0, 0.9. Legacy versions mean 1.0 and 0.9.
+    # For both of them, LVM2 has to seek to the end of every block device.
+    # If that causes performance degradation, this option can be disabled,
+    # so that the checksum can only be searched for v1.2 and v1.1 from the
+    # beginning of each device.
+    # 1 enables; 0 disables.
+    md_detect_metadata_legacy = 1
+
     # Default alignment of the start of a data area in MB.  If set to 0,
     # a value of 64KB will be used.  Set to 1 for 1MiB, 2 for 2MiB, etc.
     # default_data_alignment = @DEFAULT_DATA_ALIGNMENT@
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 529bd51..eb851cb 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -392,6 +392,11 @@ static int _process_config(struct cmd_context *cmd)
 
 	lvmetad_set_active(find_config_tree_int(cmd, "global/use_lvmetad", 0));
 
+	/* md metadata legacy(v0.9, v1.0) detection. Optional. */
+	init_md_detect_metadata_legacy(find_config_tree_bool(cmd,
+					"devices/md_detect_metadata_legacy",
+					DEFAULT_MD_DETECT_METADATA_LEGACY));
+
 	return 1;
 }
 
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index bee3d56..bf1609f 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -33,6 +33,7 @@
 #define DEFAULT_SYSFS_SCAN 1
 #define DEFAULT_MD_COMPONENT_DETECTION 1
 #define DEFAULT_MD_CHUNK_ALIGNMENT 1
+#define DEFAULT_MD_DETECT_METADATA_LEGACY 1
 #define DEFAULT_MULTIPATH_COMPONENT_DETECTION 1
 #define DEFAULT_IGNORE_SUSPENDED_DEVICES 1
 #define DEFAULT_DISABLE_AFTER_ERROR_COUNT 0
diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 4cd0a7b..40f15cb 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -225,8 +225,12 @@ int dev_is_md(struct device *dev, uint64_t *sb)
 	}
 
 	/* So you haven't found any MD magic from the beginning.
-	 * Then try again to find MD magic from the end of device.
+	 * Then try again to find MD magic from the end of device,
+	 * if md_detect_metadata_legacy option is enabled.
 	 */
+	if (!md_detect_metadata_legacy())
+		goto out;
+
 	md_offs_end[0].sb_offset = _v1_sb_offset(size, MD_MINOR_V0);	/* 1.0 */
 	md_offs_end[1].sb_offset = MD_NEW_SIZE_SECTORS(size) << SECTOR_SHIFT;	/* 0.9 */
 	len_md_offs = sizeof(md_offs_end) / sizeof(md_offs_end[0]);
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index e1512f9..323bb3c 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -49,6 +49,7 @@ static int _dev_disable_after_error_count = DEFAULT_DISABLE_AFTER_ERROR_COUNT;
 static uint64_t _pv_min_size = (DEFAULT_PV_MIN_SIZE_KB * 1024L >> SECTOR_SHIFT);
 static int _detect_internal_vg_cache_corruption =
 	DEFAULT_DETECT_INTERNAL_VG_CACHE_CORRUPTION;
+static unsigned _md_detect_metadata_legacy = DEFAULT_MD_DETECT_METADATA_LEGACY;
 
 void init_verbose(int level)
 {
@@ -163,6 +164,11 @@ void init_detect_internal_vg_cache_corruption(int detect)
 	_detect_internal_vg_cache_corruption = detect;
 }
 
+void init_md_detect_metadata_legacy(unsigned value)
+{
+	_md_detect_metadata_legacy = value;
+}
+
 void set_cmd_name(const char *cmd)
 {
 	strncpy(_cmd_name, cmd, sizeof(_cmd_name) - 1);
@@ -307,3 +313,8 @@ int detect_internal_vg_cache_corruption(void)
 {
 	return _detect_internal_vg_cache_corruption;
 }
+
+unsigned md_detect_metadata_legacy(void)
+{
+	return _md_detect_metadata_legacy;
+}
diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index 47ee9f1..868b8e8 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -137,6 +137,14 @@ has been reused without wiping the md superblocks first.
 directly upon an md device, LVM2 will align its data blocks with the
 md device's stripe-width.
 .IP
+\fBmd_detect_metadata_legacy\fP \(em If set to 1, LVM2 will try to detect
+if each device is MD device, reading MD checksums from different offsets for
+each MD versions, i.e. 1.2, 1.1, 1.0, 0.9.  Legacy versions mean 1.0 and 0.9.
+For both of them, LVM2 has to seek to the end of every block device. If that
+causes performance degradation, this option can be disabled, so that the
+checksum can only be searched for v1.2 and v1.1 from the beginning of each
+device.
+.IP
 \fBdata_alignment_detection\fP \(em If set to 1, and your kernel provides
 topology information in sysfs for the Physical Volume, the start of data
 area will be aligned on a multiple of the ?minimum_io_size? or
-- 
1.7.10


