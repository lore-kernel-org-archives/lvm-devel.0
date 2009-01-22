From: Petr Rockai <prockai@redhat.com>
Date: Thu, 22 Jan 2009 11:10:02 +0100
Subject: [PATCH 6/14] Add vg_read_error and vg_might_exist.
In-Reply-To: <1232619010-4858-6-git-send-email-prockai@redhat.com>
References: <1232619010-4858-1-git-send-email-prockai@redhat.com>
	<1232619010-4858-2-git-send-email-prockai@redhat.com>
	<1232619010-4858-3-git-send-email-prockai@redhat.com>
	<1232619010-4858-4-git-send-email-prockai@redhat.com>
	<1232619010-4858-5-git-send-email-prockai@redhat.com>
	<1232619010-4858-6-git-send-email-prockai@redhat.com>
Message-ID: <1232619010-4858-7-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Thu Jan 15 10:55:43 CET 2009  Petr Rockai <me@mornfall.net>
  * Add vg_read_error and vg_might_exist.
diff -rN -u -p old-temp.4430/lib/metadata/metadata.c new-temp.4430/lib/metadata/metadata.c
--- old-temp.4430/lib/metadata/metadata.c	2009-01-22 11:02:42.462777778 +0100
+++ new-temp.4430/lib/metadata/metadata.c	2009-01-22 11:02:42.510780457 +0100
@@ -2669,6 +2669,40 @@ vg_t *vg_read_for_update(struct cmd_cont
 }
 
 /*
+ * Check whether a vg_read (or vg_read_for_update) operation resulted in an
+ * error, or completed successfully. If EXISTENCE_CHECK has been given to
+ * vg_read, we do not consider nonexistence of the volume group an error. The
+ * caller is responsible for using vg_might_exist:
+ * - !vg_read_error(vg) && vg_might_exist(vg) -> vg is a valid handle
+ * - vg_read_error(vg) && vg_might_exist(vg) -> vg is not valid, but the VG in
+ *   question probably exists, it just cannot be opened (consult vg_read_error
+ *   return code for reason).
+ * - !vg_read_error(vg) && !vg_might_exist(vg) -> the VG does not exist
+ * - vg_read_error(vg) && !vg_might_exist(vg) -> cannot happen
+ */
+uint32_t vg_read_error(vg_t *vg)
+{
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
+/*
  * Gets/Sets for external LVM library
  */
 struct id pv_id(const pv_t *pv)
diff -rN -u -p old-temp.4430/lib/metadata/metadata-exported.h new-temp.4430/lib/metadata/metadata-exported.h
--- old-temp.4430/lib/metadata/metadata-exported.h	2009-01-22 11:02:42.462777778 +0100
+++ new-temp.4430/lib/metadata/metadata-exported.h	2009-01-22 11:02:42.510780457 +0100
@@ -399,6 +399,10 @@ vg_t *vg_read(struct cmd_context *cmd, c
 vg_t *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
                          const char *vgid, uint32_t flags);
 
+/* Queries on a (possibly error-indicating) VG handle. */
+uint32_t vg_read_error(vg_t *vg);
+uint32_t vg_might_exist(vg_t *vg);
+
 /* pe_start and pe_end relate to any existing data so that new metadata
 * areas can avoid overlap */
 pv_t *pv_create(const struct cmd_context *cmd,


