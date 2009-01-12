From: Petr Rockai <prockai@redhat.com>
Date: Mon, 12 Jan 2009 15:07:58 +0100
Subject: [PATCH 3/11] Replace implementation of vg_check_status with a call to _vg_check_status.
In-Reply-To: <1231769286-15534-3-git-send-email-prockai@redhat.com>
References: <1231769286-15534-1-git-send-email-prockai@redhat.com>
	<1231769286-15534-2-git-send-email-prockai@redhat.com>
	<1231769286-15534-3-git-send-email-prockai@redhat.com>
Message-ID: <1231769286-15534-4-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fri Jan  9 14:29:02 CET 2009  Petr Rockai <me@mornfall.net>
  * Replace implementation of vg_check_status with a call to _vg_check_status.
diff -rN -u -p old-lvmlib_apply/lib/metadata/metadata.c new-lvmlib_apply/lib/metadata/metadata.c
--- old-lvmlib_apply/lib/metadata/metadata.c	2009-01-12 14:55:48.435016898 +0100
+++ new-lvmlib_apply/lib/metadata/metadata.c	2009-01-12 14:55:48.483017901 +0100
@@ -2377,44 +2377,49 @@ int pv_analyze(struct cmd_context *cmd, 
 	return 1;
 }
 
-
-
-/**
- * vg_check_status - check volume group status flags and log error
- * @vg - volume group to check status flags
- * @status - specific status flags to check (e.g. EXPORTED_VG)
- *
- * Returns:
- * 0 - fail
- * 1 - success
- */
-int vg_check_status(const struct volume_group *vg, uint32_t status)
+static uint32_t _vg_check_status(const struct volume_group *vg, uint32_t status)
 {
+	uint32_t ret = 0;
 	if ((status & CLUSTERED) &&
 	    (vg_is_clustered(vg)) && !locking_is_clustered() &&
 	    !lockingfailed()) {
 		log_error("Skipping clustered volume group %s", vg->name);
-		return 0;
+		ret |= FAILED_CLUSTERED;
 	}
 
 	if ((status & EXPORTED_VG) &&
 	    (vg->status & EXPORTED_VG)) {
 		log_error("Volume group %s is exported", vg->name);
-		return 0;
+		ret |= FAILED_EXPORTED;
 	}
 
 	if ((status & LVM_WRITE) &&
 	    !(vg->status & LVM_WRITE)) {
 		log_error("Volume group %s is read-only", vg->name);
-		return 0;
+		ret |= FAILED_READ_ONLY;
 	}
+
 	if ((status & RESIZEABLE_VG) &&
 	    !(vg->status & RESIZEABLE_VG)) {
 		log_error("Volume group %s is not resizeable.", vg->name);
-		return 0;
+		ret |= FAILED_RESIZEABLE;
 	}
 
-	return 1;
+	return ret;
+}
+
+/**
+ * vg_check_status - check volume group status flags and log error
+ * @vg - volume group to check status flags
+ * @status - specific status flags to check (e.g. EXPORTED_VG)
+ *
+ * Returns:
+ * 0 - fail
+ * 1 - success
+ */
+int vg_check_status(const struct volume_group *vg, uint32_t status)
+{
+	return !_vg_check_status(vg, status);
 }
 
 /*
@@ -2472,37 +2477,6 @@ static vg_t *_vg_make_handle(struct cmd_
 	return vg;
 }
 
-static uint32_t _vg_check_status(const struct volume_group *vg, uint32_t status)
-{
-	uint32_t ret = 0;
-	if ((status & CLUSTERED) &&
-	    (vg_is_clustered(vg)) && !locking_is_clustered() &&
-	    !lockingfailed()) {
-		log_error("Skipping clustered volume group %s", vg->name);
-		ret |= FAILED_CLUSTERED;
-	}
-
-	if ((status & EXPORTED_VG) &&
-	    (vg->status & EXPORTED_VG)) {
-		log_error("Volume group %s is exported", vg->name);
-		ret |= FAILED_EXPORTED;
-	}
-
-	if ((status & LVM_WRITE) &&
-	    !(vg->status & LVM_WRITE)) {
-		log_error("Volume group %s is read-only", vg->name);
-		ret |= FAILED_READ_ONLY;
-	}
-
-	if ((status & RESIZEABLE_VG) &&
-	    !(vg->status & RESIZEABLE_VG)) {
-		log_error("Volume group %s is not resizeable.", vg->name);
-		ret |= FAILED_RESIZEABLE;
-	}
-
-	return ret;
-}
-
 static vg_t *_recover_vg(struct cmd_context *cmd, const char *lock,
 			 const char *vg_name, const char *vgid,
 			 uint32_t lock_flags)


