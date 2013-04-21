From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 21 Apr 2013 21:16:56 +0000 (UTC)
Subject: master - vgread: fix fid transfer for lvm1 and pool format
Message-ID: <20130421211656.A1D151241@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1951798d7225dce35baa7689a308998f27379b6f
Commit:        1951798d7225dce35baa7689a308998f27379b6f
Parent:        5e7eae59da2ce859e99c62b578f9164b87a1f944
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 21 21:36:08 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 23:13:57 2013 +0200

vgread: fix fid transfer for lvm1 and pool format

Assign fid as the last step before returning VG.
Make the format reader for 'lvm1' and 'pool' equal to 'lvm2' format reader.

It has caused memory corruption to lvmetad as it later calls
destroy_instance() to allocated fid. This patch should fix problems
with crashing test lvmetad-lvm1.sh.
---
 WHATS_NEW                     |    1 +
 lib/format1/format1.c         |    4 ++--
 lib/format_pool/format_pool.c |    4 ++--
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5d4c7a7..c1324de 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix assignment order for vg fid for lvm1 and pool format.
   Fix memleak in dmeventd thin plugin in device list obtaining err path.
   Add explicit message about unsupported pvmove for thin/thinpool volumes.
   Fix lvmetad error path in lvmetad_vg_lookup() for null vgname.
diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index f47ed95..2864227 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -200,8 +200,6 @@ static struct volume_group *_format1_vg_read(struct format_instance *fid,
 	if (dm_list_empty(&pvs))
 		goto_bad;
 
-	vg_set_fid(vg, fid);
-
 	if (!_check_vgs(&pvs, vg))
 		goto_bad;
 
@@ -226,6 +224,8 @@ static struct volume_group *_format1_vg_read(struct format_instance *fid,
 	if ((vg->status & PARTIAL_VG) && !_fix_partial_vg(vg, &pvs))
 		goto_bad;
 
+	vg_set_fid(vg, fid);
+
 	return vg;
 
 bad:
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index c051968..0891524 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -122,8 +122,6 @@ static struct volume_group *_pool_vg_read(struct format_instance *fid,
 	if (!read_pool_pds(fid->fmt, vg_name, vg->vgmem, &pds))
 		goto_bad;
 
-	vg_set_fid(vg, fid);
-
 	/* Setting pool seqno to 1 because the code always did this,
 	 * although we don't think it's needed. */
 	vg->seqno = 1;
@@ -155,6 +153,8 @@ static struct volume_group *_pool_vg_read(struct format_instance *fid,
 	if (!import_pool_segments(&vg->lvs, vg->vgmem, usp, sp_count))
 		goto_bad;
 
+	vg_set_fid(vg, fid);
+
 	return vg;
 
 bad:


