From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Dec 2011 13:10:07 -0000
Subject: LVM2/lib/activate activate.c activate.h
Message-ID: <20111221131007.18990.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-12-21 13:10:06

Modified files:
	lib/activate   : activate.c activate.h 

Log message:
	Thin add lv_thin_pool_percent

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.225&r2=1.226
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.89&r2=1.90

--- LVM2/lib/activate/activate.c	2011/12/21 13:08:13	1.225
+++ LVM2/lib/activate/activate.c	2011/12/21 13:10:05	1.226
@@ -689,6 +689,30 @@
 	return lv_mirror_percent(lv->vg->cmd, lv, 0, percent, NULL);
 }
 
+/*
+ * Returns 1 if percent set, else 0 on failure.
+ */
+int lv_thin_pool_percent(const struct logical_volume *lv, percent_t *percent)
+{
+	int r;
+	struct dev_manager *dm;
+
+	if (!activation())
+		return 0;
+
+	log_debug("Checking thin pool percent for LV %s/%s", lv->vg->name, lv->name);
+
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
+		return_0;
+
+	if (!(r = dev_manager_thin_pool_percent(dm, lv, percent)))
+		stack;
+
+	dev_manager_destroy(dm);
+
+	return r;
+}
+
 static int _lv_active(struct cmd_context *cmd, struct logical_volume *lv)
 {
 	struct lvinfo info;
--- LVM2/lib/activate/activate.h	2011/11/28 20:37:51	1.89
+++ LVM2/lib/activate/activate.h	2011/12/21 13:10:06	1.90
@@ -100,6 +100,7 @@
 int lv_mirror_percent(struct cmd_context *cmd, const struct logical_volume *lv,
 		      int wait, percent_t *percent, uint32_t *event_nr);
 int lv_raid_percent(const struct logical_volume *lv, percent_t *percent);
+int lv_thin_pool_percent(const struct logical_volume *lv, percent_t *percent);
 
 /*
  * Return number of LVs in the VG that are active.


