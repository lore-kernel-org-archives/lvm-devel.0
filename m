From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 14 Jan 2016 00:51:14 +0000 (UTC)
Subject: master - vgcfgrestore: Retain allocatable PV attribute.
Message-ID: <20160114005114.02F8660ED1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=01228b692be6850645b91811bbf30366241b036c
Commit:        01228b692be6850645b91811bbf30366241b036c
Parent:        9e9c7575413dca7a1ac7a5f363d1c7a464f86c3d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jan 14 00:46:45 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jan 14 00:46:45 2016 +0000

vgcfgrestore: Retain allocatable PV attribute.

pvchange -xn was getting lost.
All PVs were set to allocatable again after restore.

Moved setting ALLOCATABLE_PV outside pv_setup().
---
 WHATS_NEW                     |    1 +
 lib/format1/format1.c         |    6 +-----
 lib/format_text/format-text.c |    4 ----
 lib/metadata/metadata.c       |    4 ++++
 4 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index aff000f..885226a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.140 -
 ===================================
+  Fix vgcfgrestore to respect allocatable attribute of PVs.
   Add report/mark_hidden_devices to lvm.conf.
   Use brackets consistently in report fields to mark hidden devices.
   Restore background polling processing during auto-activation (2.02.119).
diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 1b86ef5..c717184 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -383,7 +383,6 @@ static int _format1_pv_setup(const struct format_type *fmt,
 			     struct physical_volume *pv,
 			     struct volume_group *vg)
 {
-	int r;
 	struct pvcreate_restorable_params rp = {.restorefile = NULL,
 						.id = {{0}},
 						.idp = NULL,
@@ -393,10 +392,7 @@ static int _format1_pv_setup(const struct format_type *fmt,
 						.extent_count = 0,
 						.extent_size = vg->extent_size};
 
-	if ((r = _format1_pv_initialise(fmt, -1, 0, 0, &rp, pv)))
-		pv->status |= ALLOCATABLE_PV;
-
-	return r;
+	return _format1_pv_initialise(fmt, -1, 0, 0, &rp, pv);
 }
 
 static int _format1_lv_setup(struct format_instance *fid, struct logical_volume *lv)
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 9aad0fe..02d3459 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1818,10 +1818,6 @@ static int _text_pv_setup(const struct format_type *fmt,
 		pv->pe_count = (uint32_t) pe_count;
 	}
 
-	/* Unlike LVM1, we don't store this outside a VG */
-	/* FIXME Default from config file? vgextend cmdline flag? */
-	pv->status |= ALLOCATABLE_PV;
-
 	return 1;
 }
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a1d2e2b..0336d5d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -227,6 +227,10 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 	 */
 	pv->pe_alloc_count = 0;
 
+	/* LVM1 stores this outside a VG; LVM2 only stores it inside */
+	/* FIXME Default from config file? vgextend cmdline flag? */
+	pv->status |= ALLOCATABLE_PV;
+
 	if (!fid->fmt->ops->pv_setup(fid->fmt, pv, vg)) {
 		log_error("Format-specific setup of physical volume '%s' "
 			  "failed.", pv_name);


