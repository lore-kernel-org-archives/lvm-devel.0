From: David Teigland <teigland@sourceware.org>
Date: Mon,  7 Nov 2022 14:56:45 +0000 (GMT)
Subject: main - device_id: look for serial number in other locations
Message-ID: <20221107145645.B26923854147@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bdab36cf3f059e597371bb504646f4dfb7a89f50
Commit:        bdab36cf3f059e597371bb504646f4dfb7a89f50
Parent:        36a923926c2c27c1a8a5ac262387d2a4d3e620f8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 24 16:23:36 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 7 08:56:02 2022 -0600

device_id: look for serial number in other locations

Only /sys/dev/block/major:minor/device/serial was read to find
a disk serial number, but a serial number seems to be reported
more often in other locations, so check these also:
/sys/dev/block/major:minor/device/vpd_pg80
/sys/class/block/vda/serial (for virtio disks only)
---
 lib/device/device.h    |  1 +
 lib/device/device_id.c | 66 ++++++++++++++++++++++++++++++++++++++++++++++++--
 lib/device/parse_vpd.c | 40 ++++++++++++++++++++++++++++++
 3 files changed, 105 insertions(+), 2 deletions(-)

diff --git a/lib/device/device.h b/lib/device/device.h
index ca46490ce..519754e41 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -228,5 +228,6 @@ int dev_mpath_init(const char *config_wwids_file);
 void dev_mpath_exit(void);
 int parse_vpd_ids(const unsigned char *vpd_data, int vpd_datalen, struct dm_list *ids);
 int format_t10_id(const unsigned char *in, int in_bytes, unsigned char *out, int out_bytes);
+int parse_vpd_serial(const unsigned char *in, char *out, int outsize);
 
 #endif
diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index bd9b3c4bf..15b34a158 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -454,6 +454,67 @@ int dev_read_sys_wwid(struct cmd_context *cmd, struct device *dev,
 	return 1;
 }
 
+static int _dev_read_sys_serial(struct cmd_context *cmd, struct device *dev,
+				char *buf, int bufsize)
+{
+	unsigned char vpd_data[VPD_SIZE] = { 0 };
+	const char *devname;
+	int vpd_datalen = 0;
+
+	/*
+	 * Look in
+	 * /sys/dev/block/major:minor/device/serial
+	 * /sys/dev/block/major:minor/device/vpd_pg80
+	 * /sys/class/block/vda/serial
+	 * (Only virtio disks /dev/vdx are known to use /sys/class/block/vdx/serial.)
+	 */
+
+	read_sys_block(cmd, dev, "device/serial", buf, bufsize);
+	if (buf[0])
+		return 1;
+
+	if (read_sys_block_binary(cmd, dev, "device/vpd_pg80", (char *)vpd_data, VPD_SIZE, &vpd_datalen) && vpd_datalen) {
+		parse_vpd_serial(vpd_data, buf, bufsize);
+		if (buf[0])
+			return 1;
+	}
+	
+	devname = dev_name(dev);
+	if (!strncmp(devname, "/dev/vd", 7)) {
+		char path[PATH_MAX];
+		char vdx[8] = { 0 };
+		const char *sysfs_dir;
+		const char *base;
+		int i, j = 0, ret;
+
+		/* /dev/vda to vda */
+		base = basename(devname);
+
+		/* vda1 to vda */
+		for (i = 0; i < strlen(base); i++) {
+			if (isdigit(base[i]))
+				break;
+			vdx[j] = base[i];
+			j++;
+		}
+
+		sysfs_dir = cmd->device_id_sysfs_dir ?: dm_sysfs_dir();
+
+		if (dm_snprintf(path, sizeof(path), "%s/class/block/%s/serial", sysfs_dir, vdx) < 0)
+			return 0;
+
+		ret = get_sysfs_value(path, buf, bufsize, 0);
+		if (ret && !buf[0])
+			ret = 0;
+		if (ret) {
+			buf[bufsize - 1] = '\0';
+			return 1;
+		}
+	}
+
+	return 0;
+}
+
 const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, uint16_t idtype)
 {
 	char sysbuf[PATH_MAX] = { 0 };
@@ -471,8 +532,9 @@ const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, u
 			sysbuf[0] = '\0';
 	}
 
-	else if (idtype == DEV_ID_TYPE_SYS_SERIAL)
-		read_sys_block(cmd, dev, "device/serial", sysbuf, sizeof(sysbuf));
+	else if (idtype == DEV_ID_TYPE_SYS_SERIAL) {
+		_dev_read_sys_serial(cmd, dev, sysbuf, sizeof(sysbuf));
+	}
 
 	else if (idtype == DEV_ID_TYPE_MPATH_UUID) {
 		read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf));
diff --git a/lib/device/parse_vpd.c b/lib/device/parse_vpd.c
index 99e8c0ec2..23b0c6efa 100644
--- a/lib/device/parse_vpd.c
+++ b/lib/device/parse_vpd.c
@@ -211,3 +211,43 @@ int parse_vpd_ids(const unsigned char *vpd_data, int vpd_datalen, struct dm_list
 
 	return id_size;
 }
+
+int parse_vpd_serial(const unsigned char *in, char *out, int outsize)
+{
+	uint8_t len_buf[2] __attribute__((aligned(8))) = { 0 };;
+	size_t len;
+
+	/* parsing code from multipath tools */
+	/* ignore in[0] and in[1] */
+	/* len is in[2] and in[3] */
+	/* serial begins@in[4] */
+
+	len_buf[0] = in[2];
+	len_buf[1] = in[3];
+	len = len_buf[0] << 8 | len_buf[1];
+
+	if (outsize == 0)
+		return 0;
+
+	if (len > DEV_WWID_SIZE)
+		len = DEV_WWID_SIZE;
+	/*
+	 * Strip leading and trailing whitespace
+	 */
+	while (len > 0 && in[len + 3] == ' ')
+		--len;
+	while (len > 0 && in[4] == ' ') {
+		++in;
+		--len;
+	}
+
+	if (len >= outsize)
+                len = outsize - 1;
+
+	if (len > 0) {
+		memcpy(out, in + 4, len);
+		out[len] = '\0';
+	}
+	return len;
+}
+

