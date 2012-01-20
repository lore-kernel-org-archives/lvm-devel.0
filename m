From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Jan 2012 03:46:52 -0000
Subject: LVM2/lib/activate activate.c
Message-ID: <20120120034652.24741.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-01-20 03:46:52

Modified files:
	lib/activate   : activate.c 

Log message:
	improve comment

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.231&r2=1.232

--- LVM2/lib/activate/activate.c	2012/01/20 00:27:19	1.231
+++ LVM2/lib/activate/activate.c	2012/01/20 03:46:52	1.232
@@ -1454,7 +1454,12 @@
 	return r;
 }
 
-/* Returns success if the device is not active */
+/*
+ * In a cluster, set exclusive to indicate that only one node is using the
+ * device.  Any preloaded tables may then use non-clustered targets.
+ *
+ * Returns success if the device is not active
+ */
 int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, unsigned exclusive)
 {
 	struct lv_activate_opts laopts = {
@@ -1541,17 +1546,18 @@
 	return r;
 }
 
-/* Returns success if the device is not active */
+/*
+ * In a cluster, set exclusive to indicate that only one node is using the
+ * device.  Any tables loaded may then use non-clustered targets.
+ *
+ * Returns success if the device is not active
+ */
 int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
-			unsigned origin_only, unsigned exclusive, unsigned revert)
+			unsigned origin_only, unsigned exclusive,
+			unsigned revert)
 {
 	struct lv_activate_opts laopts = {
 		.origin_only = origin_only,
-		/*
-		 * When targets are activated exclusively in a cluster, the
-		 * non-clustered target should be used.  This only happens
-		 * if exclusive is set.
-		 */
 		.exclusive = exclusive,
 		.revert = revert
 	};


