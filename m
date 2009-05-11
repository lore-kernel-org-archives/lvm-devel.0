From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 May 2009 09:01:37 -0400
Subject: [PATCH 24/30] Update vgmdas_disp to call liblvm 'get' function.
In-Reply-To: <1242046903-15133-24-git-send-email-dwysocha@redhat.com>
References: <1242046903-15133-1-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-2-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-3-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-4-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-5-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-6-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-7-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-8-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-9-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-10-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-11-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-12-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-13-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-14-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-15-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-16-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-17-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-18-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-19-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-20-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-21-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-22-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-23-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-24-git-send-email-dwysocha@redhat.com>
Message-ID: <1242046903-15133-25-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

No functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/lvm_object_prop.c |    3 +--
 lib/report/report.c          |    2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/lib/report/lvm_object_prop.c b/lib/report/lvm_object_prop.c
index 69a32fa..3d14ecf 100644
--- a/lib/report/lvm_object_prop.c
+++ b/lib/report/lvm_object_prop.c
@@ -809,8 +809,7 @@ int lvm_vg_set_tags(vg_t *vg, const char *value)
  */
 uint64_t lvm_vg_get_mda_count(const vg_t *vg)
 {
-	/* FIXME: implement function body */
-	return 0;
+	return dm_list_size(&vg->fid->metadata_areas);
 }
 int lvm_vg_set_mda_count(vg_t *vg, const uint64_t value)
 {
diff --git a/lib/report/report.c b/lib/report/report.c
index e0d81d5..52b800e 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1022,7 +1022,7 @@ static int _vgmdas_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct volume_group *vg = (const struct volume_group *) data;
 	uint32_t count;
 
-	count = dm_list_size(&vg->fid->metadata_areas);
+	count = lvm_vg_get_mda_count(vg);
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }
-- 
1.6.0.6


