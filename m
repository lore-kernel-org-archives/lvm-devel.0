From: Petr Rockai <prockai@redhat.com>
Date: Mon, 12 Jan 2009 15:07:59 +0100
Subject: [PATCH 4/11] Add vg_read_error and vg_might_exist.
In-Reply-To: <1231769286-15534-4-git-send-email-prockai@redhat.com>
References: <1231769286-15534-1-git-send-email-prockai@redhat.com>
	<1231769286-15534-2-git-send-email-prockai@redhat.com>
	<1231769286-15534-3-git-send-email-prockai@redhat.com>
	<1231769286-15534-4-git-send-email-prockai@redhat.com>
Message-ID: <1231769286-15534-5-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fri Jan  9 14:40:58 CET 2009  Petr Rockai <me@mornfall.net>
  * Add vg_read_error and vg_might_exist.
diff -rN -u -p old-lvmlib_apply/lib/metadata/metadata.c new-lvmlib_apply/lib/metadata/metadata.c
--- old-lvmlib_apply/lib/metadata/metadata.c	2009-01-12 14:55:50.227019233 +0100
+++ new-lvmlib_apply/lib/metadata/metadata.c	2009-01-12 14:55:50.275017512 +0100
@@ -2589,6 +2589,27 @@ static vg_t *_vg_lock_and_read(struct cm
 	return _vg_make_handle(cmd, vg, failure);
 }
 
+uint32_t vg_read_error(vg_t *vg) {
+	if (!vg)
+		return FAILED_ALLOCATION;
+	if (vg->read_failed & EXISTENCE_CHECK)
+		return vg->read_failed & ~(EXISTENCE_CHECK | FAILED_NOTFOUND);
+	return vg->read_failed;
+}
+
+/*
+ * Returns true if the volume group already exists. If unsure, it will return
+ * true (it might exist, but we are not sure, as the read failed for some other
+ * reason).
+ */
+uint32_t vg_might_exist(vg_t *vg) {
+	if (!vg)
+		return 1;
+	if (vg->read_failed == (FAILED_NOTFOUND | EXISTENCE_CHECK))
+		return 0;
+	return 1;
+}
+
 /*
  * Gets/Sets for external LVM library
  */
diff -rN -u -p old-lvmlib_apply/lib/metadata/metadata-exported.h new-lvmlib_apply/lib/metadata/metadata-exported.h
--- old-lvmlib_apply/lib/metadata/metadata-exported.h	2009-01-12 14:55:50.227019233 +0100
+++ new-lvmlib_apply/lib/metadata/metadata-exported.h	2009-01-12 14:55:50.275017512 +0100
@@ -380,6 +380,10 @@ vg_t *vg_lock_and_read(struct cmd_contex
 		       uint32_t lock_flags, uint32_t status_flags,
 		       uint32_t misc_flags);
 
+/* Queries on a (possibly error-indicating) VG handle. */
+uint32_t vg_read_error(vg_t *vg);
+uint32_t vg_might_exist(vg_t *vg);
+
 /* pe_start and pe_end relate to any existing data so that new metadata
 * areas can avoid overlap */
 pv_t *pv_create(const struct cmd_context *cmd,


