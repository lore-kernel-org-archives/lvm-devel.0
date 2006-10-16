From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Oct 2006 16:29:40 -0000
Subject: LVM2 ./WHATS_NEW tools/pvdisplay.c
Message-ID: <20061016162940.27954.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-10-16 16:29:40

Modified files:
	.              : WHATS_NEW 
	tools          : pvdisplay.c 

Log message:
	Fix pvdisplay to use vg_read() for non-orphans

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.470&r2=1.471
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/WHATS_NEW	2006/10/14 16:37:54	1.470
+++ LVM2/WHATS_NEW	2006/10/16 16:29:39	1.471
@@ -1,5 +1,6 @@
 Version 2.02.12 -
 ===================================
+  Fix pvdisplay to use vg_read() for non-orphans.
   Fall back to internal locking if external locking lib is missing or fails.
   Retain activation state after changing LV minor number with --force.
   Propagate clustered flag in vgsplit and require resizeable flag.
--- LVM2/tools/pvdisplay.c	2006/05/09 21:23:51	1.24
+++ LVM2/tools/pvdisplay.c	2006/10/16 16:29:40	1.25
@@ -19,10 +19,32 @@
 			     struct volume_group *vg __attribute((unused)),
 			     struct physical_volume *pv, void *handle)
 {
+	int consistent = 0;
+	int ret = ECMD_PROCESSED;
 	uint64_t size;
 
 	const char *pv_name = dev_name(pv->dev);
 
+	 if (pv->vg_name) {
+	         if (!lock_vol(cmd, pv->vg_name, LCK_VG_READ)) {
+	                 log_error("Can't lock %s: skipping", pv->vg_name);
+	                 return ECMD_FAILED;
+	         }
+
+	         if (!(vg = vg_read(cmd, pv->vg_name, (char *)&pv->vgid, &consistent))) {
+	                 log_error("Can't read %s: skipping", pv->vg_name);
+	                 goto out;
+	         }
+
+	         if ((vg->status & CLUSTERED) && !locking_is_clustered() &&
+	             !lockingfailed()) {
+	                 log_error("Skipping clustered volume group %s",
+	                           vg->name);
+	                 ret = ECMD_FAILED;
+	                 goto out;
+	         }
+	 }
+
 	if (!*pv->vg_name)
 		size = pv->size;
 	else
@@ -31,7 +53,7 @@
 	if (arg_count(cmd, short_ARG)) {
 		log_print("Device \"%s\" has a capacity of %s", pv_name,
 			  display_size(cmd, size));
-		return ECMD_PROCESSED;
+		goto out;
 	}
 
 	if (pv->status & EXPORTED_VG)
@@ -44,15 +66,19 @@
 
 	if (arg_count(cmd, colon_ARG)) {
 		pvdisplay_colons(pv);
-		return ECMD_PROCESSED;
+		goto out;
 	}
 
 	pvdisplay_full(cmd, pv, handle);
 
 	if (!arg_count(cmd, maps_ARG))
-		return ECMD_PROCESSED;
+		goto out;
+
+out:
+        if (pv->vg_name)
+                unlock_vg(cmd, pv->vg_name);
 
-	return ECMD_PROCESSED;
+	return ret;
 }
 
 int pvdisplay(struct cmd_context *cmd, int argc, char **argv)


