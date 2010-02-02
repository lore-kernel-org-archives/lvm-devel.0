From: Malahal Naineni <malahal@us.ibm.com>
Date: Mon, 01 Feb 2010 16:00:18 -0800
Subject: [PATCH] Monitor log volume if it is a mirror
Message-ID: <a40ce4ac6ed447ed3e5f.1265068818@localhost>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Log volume of a mirror can also be a mirror with the following patchset.
http://thread.gmane.org/gmane.linux.kernel.device-mapper.devel/10232
If so, monitor such log volumes.

Signed-off-by: Malahal Naineni (malahal at us.ibm.com)

diff -r 15e7d25bb86a -r a40ce4ac6ed4 lib/activate/activate.c
--- a/lib/activate/activate.c	Mon Feb 01 15:50:20 2010 -0800
+++ b/lib/activate/activate.c	Mon Feb 01 15:54:59 2010 -0800
@@ -737,6 +737,7 @@ int monitor_dev_for_events(struct cmd_co
 	int r = 1;
 	struct dm_list *tmp, *snh, *snht;
 	struct lv_segment *seg;
+	struct lv_segment *log_seg;
 	int (*monitor_fn) (struct lv_segment *s, int e);
 	uint32_t s;
 
@@ -772,6 +773,16 @@ int monitor_dev_for_events(struct cmd_co
 		return r;
 	}
 
+	/*
+	 * If the volume is mirrored and its log is also mirrored, monitor
+	 * the log volume as well.
+	 */
+	if ((seg = first_seg(lv)) != NULL && seg->log_lv != NULL &&
+	    (log_seg = first_seg(seg->log_lv)) != NULL &&
+	    seg_is_mirrored(log_seg))
+		if (!monitor_dev_for_events(cmd, seg->log_lv, monitor))
+			r = 0;
+
 	dm_list_iterate(tmp, &lv->segments) {
 		seg = dm_list_item(tmp, struct lv_segment);
 


