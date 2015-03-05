From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  5 Mar 2015 16:23:48 +0000 (UTC)
Subject: master - system_id: avoid munging vg and lv fields
Message-ID: <20150305162348.1991C60E97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5e25bca1a98f2376b94904a2e220a3e2f68923ad
Commit:        5e25bca1a98f2376b94904a2e220a3e2f68923ad
Parent:        8bb76aea81574042c6010291a8c799a90570b0d3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 5 10:23:16 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 5 10:23:16 2015 -0600

system_id: avoid munging vg and lv fields

Munge the WRITE/WRITE_LOCKED flags in a temp variable
instead of in the vg/lv fields.
---
 lib/format_text/export.c |   28 ++++++++++------------------
 1 files changed, 10 insertions(+), 18 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index ec01fcc..2d985b4 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -394,6 +394,7 @@ static int _print_vg(struct formatter *f, struct volume_group *vg)
 {
 	char buffer[4096];
 	const struct format_type *fmt = NULL;
+	uint64_t status = vg->status;
 
 	if (!id_write_format(&vg->id, buffer, sizeof(buffer)))
 		return_0;
@@ -413,19 +414,14 @@ static int _print_vg(struct formatter *f, struct volume_group *vg)
 	 * Removing WRITE and adding WRITE_LOCKED makes it read-only
 	 * to old versions of lvm that only look for WRITE.
 	 */
-	if ((vg->status & LVM_WRITE) && vg_flag_write_locked(vg)) {
-		vg->status &= ~LVM_WRITE;
-		vg->status |= LVM_WRITE_LOCKED;
+	if ((status & LVM_WRITE) && vg_flag_write_locked(vg)) {
+		status &= ~LVM_WRITE;
+		status |= LVM_WRITE_LOCKED;
 	}
 
-	if (!_print_flag_config(f, vg->status, VG_FLAGS))
+	if (!_print_flag_config(f, status, VG_FLAGS))
 		return_0;
 
-	if (vg->status & LVM_WRITE_LOCKED) {
-		vg->status |= LVM_WRITE;
-		vg->status &= ~LVM_WRITE_LOCKED;
-	}
-
 	if (!_out_tags(f, &vg->tags))
 		return_0;
  
@@ -621,6 +617,7 @@ static int _print_lv(struct formatter *f, struct logical_volume *lv)
 	int seg_count;
 	struct tm *local_tm;
 	time_t ts;
+	uint64_t status = lv->status;
 
 	outnl(f);
 	outf(f, "%s {", lv->name);
@@ -636,19 +633,14 @@ static int _print_lv(struct formatter *f, struct logical_volume *lv)
 	 * Removing WRITE and adding WRITE_LOCKED makes it read-only
 	 * to old versions of lvm that only look for WRITE.
 	 */
-	if ((lv->status & LVM_WRITE) && vg_flag_write_locked(lv->vg)) {
-		lv->status &= ~LVM_WRITE;
-		lv->status |= LVM_WRITE_LOCKED;
+	if ((status & LVM_WRITE) && vg_flag_write_locked(lv->vg)) {
+		status &= ~LVM_WRITE;
+		status |= LVM_WRITE_LOCKED;
 	}
 
-	if (!_print_flag_config(f, lv->status, LV_FLAGS))
+	if (!_print_flag_config(f, status, LV_FLAGS))
 		return_0;
 
-	 if (lv->status & LVM_WRITE_LOCKED) {
-		lv->status |= LVM_WRITE;
-		lv->status &= ~LVM_WRITE_LOCKED;
-	 }
-
 	if (!_out_tags(f, &lv->tags))
 		return_0;
 


