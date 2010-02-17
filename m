From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 17 Feb 2010 11:57:18 -0600
Subject: [PATCH 10 of 13] LVM: monitor mirrored logs
Message-ID: <201002171757.o1HHvIIC005055@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-monitor-mirrored-logs.patch

Log volume of a mirror can also be a mirror with the following patchset.
http://thread.gmane.org/gmane.linux.kernel.device-mapper.devel/10232
If so, monitor such log volumes.

Signed-off-by: Malahal Naineni (malahal at us.ibm.com)

Index: LVM2/lib/activate/activate.c
===================================================================
--- LVM2.orig/lib/activate/activate.c
+++ LVM2/lib/activate/activate.c
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
 


