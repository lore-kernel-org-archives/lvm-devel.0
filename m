From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 11 Mar 2010 18:30:58 -0600
Subject: [PATCH 7 of 11] LVM: monitor mirrored logs
Message-ID: <201003120030.o2C0UwhU028310@hydrogen.msp.redhat.com>
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
@@ -703,6 +703,7 @@ int monitor_dev_for_events(struct cmd_co
 	int r = 1;
 	struct dm_list *tmp, *snh, *snht;
 	struct lv_segment *seg;
+	struct lv_segment *log_seg;
 	int (*monitor_fn) (struct lv_segment *s, int e);
 	uint32_t s;
 
@@ -738,6 +739,16 @@ int monitor_dev_for_events(struct cmd_co
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
 


