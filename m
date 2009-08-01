From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 1 Aug 2009 17:07:38 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf lib/config/d ...
Message-ID: <20090801170738.1959.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-08-01 17:07:37

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf 
	lib/config     : defaults.h 
	lib/device     : device.c device.h 
	lib/format_text: format-text.c 
	lib/metadata   : metadata.c 
	man            : lvm.conf.5.in 

Log message:
	Add devices/data_alignment_offset_detection to lvm.conf.
	
	If the pvcreate --dataalignmentoffset option is not specified the start
	of a PV's aligned data area will be shifted by the associated
	'alignment_offset' exposed in sysfs (unless
	devices/data_alignment_offset_detection is disabled in lvm.conf).
	
	Signed-off-by: Mike Snitzer <snitzer@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1223&r2=1.1224
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.h.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.275&r2=1.276
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW	2009/07/31 18:30:31	1.1223
+++ LVM2/WHATS_NEW	2009/08/01 17:07:36	1.1224
@@ -4,6 +4,7 @@
   Added configure --enable-udev_rules --enable-udev_sync.
   Added configure --with-udev-prefix --with-udevdir.
   Added udev dir to hold udev rules.
+  Add devices/data_alignment_offset_detection to lvm.conf.
   Add --dataalignmentoffset to pvcreate to shift start of aligned data area.
   Fix _mda_setup() to not check first mda's size before pe_align rounding.
   Document -I option of clvmd in the man page.
--- LVM2/doc/example.conf	2009/07/24 23:29:03	1.42
+++ LVM2/doc/example.conf	2009/08/01 17:07:36	1.43
@@ -104,6 +104,15 @@
     # Set to 0 for the default alignment of 64KB or page size, if larger.
     data_alignment = 0
 
+    # By default, the start of the PV's aligned data area will be shifted by
+    # the 'alignment_offset' exposed in sysfs.  This offset is often 0 but
+    # may be non-zero; e.g.: certain 4KB sector drives that compensate for
+    # windows partitioning will have an alignment_offset of 3584 bytes
+    # (sector 7 is the lowest aligned logical block, the 4KB sectors start
+    # at LBA -1, and consequently sector 63 is aligned on a 4KB boundary).
+    # 1 enables; 0 disables.
+    data_alignment_offset_detection = 1
+
     # If, while scanning the system for PVs, LVM2 encounters a device-mapper
     # device that has its I/O suspended, it waits for it to become accessible.
     # Set this to 1 to skip such devices.  This should only be needed
--- LVM2/lib/config/defaults.h	2009/07/24 23:29:03	1.47
+++ LVM2/lib/config/defaults.h	2009/08/01 17:07:37	1.48
@@ -34,6 +34,7 @@
 #define DEFAULT_MD_COMPONENT_DETECTION 1
 #define DEFAULT_MD_CHUNK_ALIGNMENT 1
 #define DEFAULT_IGNORE_SUSPENDED_DEVICES 1
+#define DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION 1
 
 #define DEFAULT_LOCK_DIR "/var/lock/lvm"
 #define DEFAULT_LOCKING_LIB "liblvm2clusterlock.so"
--- LVM2/lib/device/device.c	2009/07/09 22:50:45	1.27
+++ LVM2/lib/device/device.c	2009/08/01 17:07:37	1.28
@@ -282,3 +282,74 @@
 	return 0;
 }
 #endif
+
+#ifdef linux
+
+static unsigned long _dev_topology_attribute(const char *attribute,
+					     const char *sysfs_dir,
+					     struct device *dev)
+{
+	char path[PATH_MAX+1], buffer[64];
+	FILE *fp;
+	struct stat info;
+	unsigned long result = 0UL;
+
+	if (!attribute || !*attribute)
+		return_0;
+
+	if (!sysfs_dir || !*sysfs_dir)
+		return_0;
+
+	if (dm_snprintf(path, PATH_MAX, "%s/dev/block/%d:%d/%s",
+			sysfs_dir, (int)MAJOR(dev->dev), (int)MINOR(dev->dev),
+			attribute) < 0) {
+		log_error("dm_snprintf %s failed", attribute);
+		return 0;
+	}
+
+	/* check if the desired sysfs attribute exists */
+	if (stat(path, &info) < 0)
+		return 0;
+
+	if (!(fp = fopen(path, "r"))) {
+		log_sys_error("fopen", path);
+		return 0;
+	}
+
+	if (!fgets(buffer, sizeof(buffer), fp)) {
+		log_sys_error("fgets", path);
+		goto out;
+	}
+
+	if (sscanf(buffer, "%lu", &result) != 1) {
+		log_error("sysfs file %s not in expected format: %s", path,
+			  buffer);
+		goto out;
+	}
+
+	log_very_verbose("Device %s %s is %lu bytes.",
+			 dev_name(dev), attribute, result);
+
+out:
+	if (fclose(fp))
+		log_sys_error("fclose", path);
+
+	return result >> SECTOR_SHIFT;
+}
+
+unsigned long dev_alignment_offset(const char *sysfs_dir,
+				   struct device *dev)
+{
+	return _dev_topology_attribute("alignment_offset",
+				       sysfs_dir, dev);
+}
+
+#else
+
+unsigned long dev_alignment_offset(const char *sysfs_dir,
+				   struct device *dev)
+{
+	return 0UL;
+}
+
+#endif
--- LVM2/lib/device/device.h	2009/07/06 19:04:25	1.40
+++ LVM2/lib/device/device.h	2009/08/01 17:07:37	1.41
@@ -100,4 +100,7 @@
 
 int is_partitioned_dev(struct device *dev);
 
+unsigned long dev_alignment_offset(const char *sysfs_dir,
+				   struct device *dev);
+
 #endif
--- LVM2/lib/format_text/format-text.c	2009/07/31 14:23:06	1.114
+++ LVM2/lib/format_text/format-text.c	2009/08/01 17:07:37	1.115
@@ -1772,7 +1772,11 @@
 				 "%lu sectors (requested %lu sectors)",
 				 pv_dev_name(pv), pv->pe_align, data_alignment);
 
-		set_pe_align_offset(pv, data_alignment_offset);
+		if (set_pe_align_offset(pv, data_alignment_offset) != data_alignment_offset &&
+		    data_alignment_offset)
+			log_warn("WARNING: %s: Overriding data alignment offset to "
+				 "%lu sectors (requested %lu sectors)",
+				 pv_dev_name(pv), pv->pe_align_offset, data_alignment_offset);
 
 		if (pv->pe_align < pv->pe_align_offset) {
 			log_error("%s: pe_align (%lu sectors) must not be less "
--- LVM2/lib/metadata/metadata.c	2009/07/30 17:45:29	1.275
+++ LVM2/lib/metadata/metadata.c	2009/08/01 17:07:37	1.276
@@ -105,6 +105,14 @@
 	if (!pv->dev)
 		goto out;
 
+	if (find_config_tree_bool(pv->fmt->cmd,
+				  "devices/data_alignment_offset_detection",
+				  DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION))
+		pv->pe_align_offset =
+			MAX(pv->pe_align_offset,
+			    dev_alignment_offset(pv->fmt->cmd->sysfs_dir,
+						 pv->dev));
+
 	log_very_verbose("%s: Setting PE alignment offset to %lu sectors.",
 			 dev_name(pv->dev), pv->pe_align_offset);
 
--- LVM2/man/lvm.conf.5.in	2009/07/24 23:29:03	1.4
+++ LVM2/man/lvm.conf.5.in	2009/08/01 17:07:37	1.5
@@ -142,10 +142,17 @@
 If a Physical Volume is placed directly upon an md device and
 \fBmd_chunk_alignment\fP is enabled this parameter is ignored.
 Set to 0 to use the default alignment of 64KB or the page size, if larger.
+.IP
+\fBdata_alignment_offset_detection\fP \(em If set to 1, and your kernel
+provides topology information in sysfs for the Physical Volume, the
+start of the aligned data area of the Physical Volume will be shifted
+by the alignment_offset exposed in sysfs.
 .sp
 To see the location of the first Physical Extent of an existing Physical Volume
 use \fBpvs -o +pe_start\fP .  It will be a multiple of the requested
-\fBdata_alignment\fP.
+\fBdata_alignment\fP plus the alignment_offset from
+\fBdata_alignment_offset_detection\fP (if enabled) or the pvcreate
+commandline.
 .TP
 \fBlog\fP \(em Default log settings
 .IP


