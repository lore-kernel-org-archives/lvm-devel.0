From: David Teigland <teigland@sourceware.org>
Date: Mon,  6 Feb 2023 18:24:59 +0000 (GMT)
Subject: main - device_id: ignore quotes in device id
Message-ID: <20230206182459.14A033858D1E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dc99f0def17b936f95c63612a56ae2a6ae81db0e
Commit:        dc99f0def17b936f95c63612a56ae2a6ae81db0e
Parent:        57ad78d4369ee531ab0173b42aa91048eb316353
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 6 12:18:55 2023 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 6 12:24:18 2023 -0600

device_id: ignore quotes in device id

A t10 wwid string was found containing a " character
which breaks vg metadata parsing.  Ignore any quotation
marks in device id strings.
---
 lib/device/device_id.c            |  6 ++++--
 lib/device/parse_vpd.c            |  6 ++++++
 test/shell/devicesfile-vpd-ids.sh | 24 ++++++++++++++++++++++++
 3 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 1be6b0787..79da12884 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -438,8 +438,8 @@ int dev_read_sys_wwid(struct cmd_context *cmd, struct device *dev,
 	if (!ret || !buf[0])
 		return 0;
 
-	/* in t10 id, replace series of spaces with one _ */
-	if (!strncmp(buf, "t10.", 4) && strchr(buf, ' ')) {
+	/* in t10 id, replace characters like space and quote */
+	if (!strncmp(buf, "t10.", 4)) {
 		if (bufsize < DEV_WWID_SIZE)
 			return 0;
 		memcpy(tmpbuf, buf, DEV_WWID_SIZE);
@@ -587,6 +587,8 @@ const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, u
 	/* wwids are already munged if needed */
 	if (idtype != DEV_ID_TYPE_SYS_WWID) {
 		for (i = 0; i < strlen(sysbuf); i++) {
+			if (sysbuf[i] == '"')
+				continue;
 			if (isblank(sysbuf[i]) || isspace(sysbuf[i]) || iscntrl(sysbuf[i]))
 				sysbuf[i] = '_';
 		}
diff --git a/lib/device/parse_vpd.c b/lib/device/parse_vpd.c
index bea8834d4..c1ac974fd 100644
--- a/lib/device/parse_vpd.c
+++ b/lib/device/parse_vpd.c
@@ -53,6 +53,12 @@ int format_t10_id(const unsigned char *in, int in_bytes, unsigned char *out, int
 		/* skip leading spaces */
 		if (!retlen && (in[i] == ' '))
 			continue;
+		/* skip non-ascii non-printable characters */
+		if (!isascii(in[i]) || !isprint(in[i]))
+			continue;
+		/* skip quote */
+		if (in[i] == '"')
+			continue;
 		/* replace one or more spaces with _ */
 		if (in[i] == ' ') {
 			in_space = 1;
diff --git a/test/shell/devicesfile-vpd-ids.sh b/test/shell/devicesfile-vpd-ids.sh
index 2801310ef..b2042fb9a 100644
--- a/test/shell/devicesfile-vpd-ids.sh
+++ b/test/shell/devicesfile-vpd-ids.sh
@@ -219,6 +219,30 @@ vgremove $vg
 rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
 cleanup_sysfs
 
+# Test t10 wwid containing quote
+rm $DF
+aux wipefs_a "$DEV1"
+mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/
+echo "t10.ATA_2.5\"_SATA_SSD_1112-A___111111111111" > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
+lvmdevices --adddev "$DEV1"
+cat $DF
+vgcreate $vg "$DEV1"
+lvcreate -l1 -an $vg
+cat $DF
+# check wwid string in metadata output
+pvs -o+deviceidtype,deviceid "$DEV1" |tee out
+grep sys_wwid out
+# the quote is removed after the 5
+grep 2.5_SATA_SSD out
+# check wwid string in system.devices
+grep sys_wwid $DF
+# the quote is removed after the 5
+grep 2.5_SATA_SSD $DF
+lvremove -y $vg
+vgremove $vg
+rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
+cleanup_sysfs
+
 # TODO: lvmdevices --adddev <dev> --deviceidtype <type> --deviceid <val>
 # This would let the user specify the second naa wwid.
 

