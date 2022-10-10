From: David Teigland <teigland@sourceware.org>
Date: Mon, 10 Oct 2022 16:47:55 +0000 (GMT)
Subject: main - device id: change space handling in t10 wwid
Message-ID: <20221010164755.7BB083858288@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8de87e0207342b0142778ebe9c51f0d552adfab8
Commit:        8de87e0207342b0142778ebe9c51f0d552adfab8
Parent:        380ab3f45c48f016fcebe4105bb94b8f024bae71
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 31 15:59:28 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 10 11:47:29 2022 -0500

device id: change space handling in t10 wwid

t10 wwids are now edited in the same way that multipath does,
which is replacing a series of spaces with one _.  Previously
lvm replaced every space with one _.  Devices file entries
with the old form will be converted to the new shorter form.
---
 lib/device/device_id.c | 61 +++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 58 insertions(+), 3 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 3dd428df8..5481bb6b0 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -400,6 +400,7 @@ int dev_read_vpd_wwids(struct cmd_context *cmd, struct device *dev)
 int dev_read_sys_wwid(struct cmd_context *cmd, struct device *dev,
 		      char *buf, int bufsize, struct dev_wwid **dw_out)
 {
+	char tmpbuf[DEV_WWID_SIZE];
 	struct dev_wwid *dw;
 	int ret;
 
@@ -413,6 +414,15 @@ int dev_read_sys_wwid(struct cmd_context *cmd, struct device *dev,
 	if (!ret || !buf[0])
 		return 0;
 
+	/* in t10 id, replace series of spaces with one _ */
+	if (!strncmp(buf, "t10.", 4) && strchr(buf, ' ')) {
+		if (bufsize < DEV_WWID_SIZE)
+			return 0;
+		memcpy(tmpbuf, buf, DEV_WWID_SIZE);
+		memset(buf, 0, bufsize);
+		format_t10_id((const unsigned char *)tmpbuf, DEV_WWID_SIZE, (unsigned char *)buf, bufsize);
+	}
+
 	/* Note, if wwids are also read from vpd, this same wwid will be added again. */
 
 	if (!(dw = dev_add_wwid(buf, 0, &dev->wwids)))
@@ -475,9 +485,12 @@ const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, u
 		return idname;
 	}
 
-	for (i = 0; i < strlen(sysbuf); i++) {
-		if (isblank(sysbuf[i]) || isspace(sysbuf[i]) || iscntrl(sysbuf[i]))
-			sysbuf[i] = '_';
+	/* wwids are already munged if needed */
+	if (idtype != DEV_ID_TYPE_SYS_WWID) {
+		for (i = 0; i < strlen(sysbuf); i++) {
+			if (isblank(sysbuf[i]) || isspace(sysbuf[i]) || iscntrl(sysbuf[i]))
+				sysbuf[i] = '_';
+		}
 	}
 
 	if (!sysbuf[0])
@@ -1551,6 +1564,28 @@ static int _match_dm_devnames(struct cmd_context *cmd, struct device *dev,
 	return 0;
 }
 
+static void _reduce_underscores(char *in, int in_len, char *out, int out_size)
+{
+	int us = 0, i, j = 0;
+
+	for (i = 0; i < in_len; i++) {
+		if (in[i] == '_')
+			us++;
+		else
+			us = 0;
+
+		if (us == 1)
+			out[j++] = '_';
+		else if (us > 1)
+			continue;
+		else
+			out[j++] = in[i];
+
+		if (j == out_size)
+			break;
+	}
+}
+
 /*
  * du is a devices file entry.  dev is any device on the system.
  * check if du is for dev by comparing the device's ids to du->idname.
@@ -1564,6 +1599,7 @@ static int _match_dm_devnames(struct cmd_context *cmd, struct device *dev,
 
 static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct device *dev)
 {
+	char du_t10[DEV_WWID_SIZE] = { 0 };
 	struct dev_id *id;
 	const char *idname;
 	int part;
@@ -1613,6 +1649,16 @@ static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct
 		return 0;
 	}
 
+	/*
+	 * Devices file entries with IDTYPE=sys_wwid and a T10 WWID
+	 * for IDNAME were saved in the past with each space replaced
+	 * by one _.  Now we convert multiple spaces to a single _.
+	 * So, convert a df entry with the old style to the new shorter
+	 * style to compare.
+	 */
+	if (du->idtype == DEV_ID_TYPE_SYS_WWID && !strncmp(du->idname, "t10", 3) && strstr(du->idname, "__"))
+		_reduce_underscores(du->idname, strlen(du->idname), du_t10, sizeof(du_t10) - 1);
+
 	/*
 	 * Try to match du with ids that have already been read for the dev
 	 * (and saved on dev->ids to avoid rereading.)
@@ -1636,6 +1682,15 @@ static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct
 					  idtype_to_str(du->idtype), du->idname, dev_name(dev));
 				return 1;
 
+			} else if ((id->idtype == DEV_ID_TYPE_SYS_WWID) && !strncmp(id->idname, "t10", 3) &&
+				    du_t10[0] && !strcmp(id->idname, du_t10)) {
+				/* Compare the shorter form du t10 wwid to the dev t10 wwid. */
+				du->dev = dev;
+				dev->id = id;
+				dev->flags |= DEV_MATCHED_USE_ID;
+				log_debug("Match device_id %s %s to %s",
+					  idtype_to_str(du->idtype), du->idname, dev_name(dev));
+				return 1;
 			} else {
 				/*
 				log_debug("Mismatch device_id %s %s to %s: idname %s",

