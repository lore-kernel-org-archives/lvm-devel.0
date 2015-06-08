From: Lidong Zhong <lzhong@suse.com>
Date: Mon,  8 Jun 2015 15:48:29 +0800
Subject: [RFC 3/6] Mark a device if already being waited
In-Reply-To: <1433749712-11837-1-git-send-email-lzhong@suse.com>
References: <1433749712-11837-1-git-send-email-lzhong@suse.com>
Message-ID: <1433749712-11837-4-git-send-email-lzhong@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We use a file named by uuid of the missing device under /tmp to identify
if this device is already being waited. In case of there are two or more
missing device in one mirror, we keep waiting for the same device.
Fix me if there is other good idea.
---
 tools/lvconvert.c | 43 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index fe8b761..8fcbefd 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -962,6 +962,49 @@ static void _lvconvert_mirrors_repair_ask(struct cmd_context *cmd,
 }
 
 /*
+ * Here we use a tmp file named UUID of pv under /tmp
+ * to identify if this device already being waited.
+ */
+#define WAITING_DIR  "/tmp/"
+static int already_being_waited(struct physical_volume *pv)
+{
+	char uuid[64];
+	char path[70];
+	FILE *fp;
+	int r = 0;
+
+	id_write_format(&pv->id, uuid, 64);
+	sprintf(path, WAITING_DIR"%s", uuid);
+	fp = fopen(path, "r");
+	if (!fp) {
+		fp = fopen(path, "w");
+		fclose(fp);
+	} else
+		r = 1;
+	return r;
+}
+
+static int remove_device_from_waiting_dir(struct physical_volume *pv)
+{
+	char uuid[64];
+	char path[70];
+	FILE *fp;
+	int r = 1;
+
+	id_write_format(&pv->id, uuid, 64);
+	sprintf(path, WAITING_DIR"%s", uuid);
+	fp = fopen(path, "r");
+	if (!fp) {
+		log_error("It should open the file successfully");
+		r = 0;
+	} else {
+		fclose(fp);
+		remove(path);
+	}
+	return r;
+}
+
+/*
  * _get_log_count
  * @lv: the mirror LV
  *
-- 
1.8.1.4


