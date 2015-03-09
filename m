From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  9 Mar 2015 18:57:25 +0000 (UTC)
Subject: master - comments: Use full flag names.
Message-ID: <20150309185725.48D35610C3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=faccdeda83ee8c04546a2224fa2dee82a55413fe
Commit:        faccdeda83ee8c04546a2224fa2dee82a55413fe
Parent:        e9a233ee8ef362fccc5537125a19c28e5d596168
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Mar 9 18:53:22 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Mar 9 18:53:22 2015 +0000

comments: Use full flag names.

---
 lib/format_text/export.c         |    8 ++++----
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/metadata.c          |   14 +++++++-------
 3 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 2d985b4..018772e 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -411,8 +411,8 @@ static int _print_vg(struct formatter *f, struct volume_group *vg)
 		outfc(f, "# informational", "format = \"%s\"", fmt->name);
 
 	/*
-	 * Removing WRITE and adding WRITE_LOCKED makes it read-only
-	 * to old versions of lvm that only look for WRITE.
+	 * Removing WRITE and adding LVM_WRITE_LOCKED makes it read-only
+	 * to old versions of lvm that only look for LVM_WRITE.
 	 */
 	if ((status & LVM_WRITE) && vg_flag_write_locked(vg)) {
 		status &= ~LVM_WRITE;
@@ -630,8 +630,8 @@ static int _print_lv(struct formatter *f, struct logical_volume *lv)
 	outf(f, "id = \"%s\"", buffer);
 
 	/*
-	 * Removing WRITE and adding WRITE_LOCKED makes it read-only
-	 * to old versions of lvm that only look for WRITE.
+	 * Removing WRITE and adding LVM_WRITE_LOCKED makes it read-only
+	 * to old versions of lvm that only look for LVM_WRITE.
 	 */
 	if ((status & LVM_WRITE) && vg_flag_write_locked(lv->vg)) {
 		status &= ~LVM_WRITE;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b5ab1f2..414216a 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -58,6 +58,7 @@
 
 #define LVM_READ		UINT64_C(0x0000000000000100)	/* LV, VG */
 #define LVM_WRITE		UINT64_C(0x0000000000000200)	/* LV, VG */
+#define LVM_WRITE_LOCKED	UINT64_C(0x0020000000000000)    /* LV, VG */
 
 #define CLUSTERED		UINT64_C(0x0000000000000400)	/* VG */
 //#define SHARED		UINT64_C(0x0000000000000800)	/* VG */
@@ -122,7 +123,6 @@
 #define PV_ALLOCATION_PROHIBITED	UINT64_C(0x0010000000000000)	/* PV - internal use only - allocation prohibited
 									e.g. to prohibit allocation of a RAID image
 									on a PV already holing an image of the RAID set */
-#define LVM_WRITE_LOCKED	UINT64_C(0x0020000000000000)    /* VG, LV */
 /* Next unused flag:		UINT64_C(0x0040000000000000)    */
 
 /* Format features flags */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index f495bdd..ab23d25 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4249,22 +4249,22 @@ int vg_check_write_mode(struct volume_group *vg)
 
 /*
  * Return 1 if the VG metadata should be written
- * *without* the WRITE flag in the status line, and
- * *with* the WRITE_LOCKED flag in the flags line.
+ * *without* the LVM_WRITE flag in the status line, and
+ * *with* the LVM_WRITE_LOCKED flag in the flags line.
  *
  * If this is done for a VG, it forces previous versions
- * of lvm (before the WRITE_LOCKED flag was added), to view
- * the VG and its LVs as read-only (because the WRITE flag
+ * of lvm (before the LVM_WRITE_LOCKED flag was added), to view
+ * the VG and its LVs as read-only (because the LVM_WRITE flag
  * is missing).  Versions of lvm that understand the
- * WRITE_LOCKED flag know to check the other methods of
+ * LVM_WRITE_LOCKED flag know to check the other methods of
  * access control for the VG, specifically system_id and lock_type.
  *
  * So, if a VG has a system_id or lock_type, then the
  * system_id and lock_type control access to the VG in
  * addition to its basic writable status.  Because previous
  * lvm versions do not know about system_id or lock_type,
- * VGs depending on either of these should have WRITE_LOCKED
- * instead of WRITE to prevent the previous lvm versions from
+ * VGs depending on either of these should have LVM_WRITE_LOCKED
+ * instead of LVM_WRITE to prevent the previous lvm versions from
  * assuming they can write the VG and its LVs.
  */
 int vg_flag_write_locked(struct volume_group *vg)


