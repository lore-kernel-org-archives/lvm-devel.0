From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 25 Jun 2010 22:53:02 -0400
Subject: [PATCH 31/38] Ensure fid mda lists are populated correctly during vgextend.
In-Reply-To: <1277520789-6808-31-git-send-email-dwysocha@redhat.com>
References: <1277520789-6808-1-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-2-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-3-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-4-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-5-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-6-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-7-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-8-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-9-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-10-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-11-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-12-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-13-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-14-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-15-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-16-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-17-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-18-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-19-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-20-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-21-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-22-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-23-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-24-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-25-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-26-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-27-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-28-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-29-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-30-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-31-git-send-email-dwysocha@redhat.com>
Message-ID: <1277520789-6808-32-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The vgextend path calls add_pv_to_vg().  Inside add_pv_to_vg(),
we must ensure we pass the correct mdas list into pv_setup(), as
copies of mdas are placed on the vg->fid list.  If we don't place
the mdas on the correct vg->fid list, the various counts may be
incorrect and the metadata balance algorithm will not work when
called from vg_write() path.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   18 +++++++++++++++++-
 1 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b9e4e39..58060f7 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -174,6 +174,7 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 	struct format_instance *fid = vg->fid;
 	struct dm_pool *mem = vg->vgmem;
 	char uuid[64] __attribute((aligned(8)));
+	struct dm_list *mdas;
 
 	log_verbose("Adding physical volume '%s' to volume group '%s'",
 		    pv_name, vg->name);
@@ -217,9 +218,24 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 	 */
 	pv->pe_alloc_count = 0;
 
+	/*
+	 * FIXME: this does not work entirely correctly in the case where a PV
+	 * has 2 mdas and only one is ignored; ideally all non-ignored mdas
+	 * should be placed on metadata_areas list and ignored on the
+	 * metadata_areas_ignored list; however this requires another
+	 * fairly complex refactoring to remove the 'mdas' parameter from both
+	 * pv_setup and pv_write.  For now, we only put ignored mdas on the
+	 * metadata_areas_ignored list if all mdas in the PV are ignored;
+	 * otherwise, we use the non-ignored list.
+	 */
+	if (!pv_mda_used_count(pv))
+		mdas = &fid->metadata_areas_ignored;
+	else
+		mdas = &fid->metadata_areas;
+
 	if (!fid->fmt->ops->pv_setup(fid->fmt, UINT64_C(0), 0,
 				     vg->extent_size, 0, 0, 0UL, UINT64_C(0),
-				     &fid->metadata_areas, pv, vg)) {
+				     mdas, pv, vg)) {
 		log_error("Format-specific setup of physical volume '%s' "
 			  "failed.", pv_name);
 		return 0;
-- 
1.6.0.6


