From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 21 Jun 2010 23:05:57 -0400
Subject: [PATCH 24/35] Add vg get/set methods for VG metadata copies.
In-Reply-To: <1277175968-9661-24-git-send-email-dwysocha@redhat.com>
References: <1277175968-9661-1-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-2-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-3-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-4-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-5-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-6-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-7-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-8-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-9-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-10-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-11-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-12-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-13-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-14-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-15-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-16-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-17-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-18-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-19-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-20-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-21-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-22-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-23-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-24-git-send-email-dwysocha@redhat.com>
Message-ID: <1277175968-9661-25-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds the get and partially implemented set function.
The 'set' function should probably ignore or un-ignore metadata areas
based on new values.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    2 ++
 lib/metadata/metadata.c          |   16 ++++++++++++++++
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 4388587..b444e34 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -877,6 +877,8 @@ uint64_t vg_max_pv(const struct volume_group *vg);
 uint64_t vg_max_lv(const struct volume_group *vg);
 uint32_t vg_mda_count(const struct volume_group *vg);
 uint32_t vg_mda_count_ignored(const struct volume_group *vg);
+uint32_t vg_mda_copies(const struct volume_group *vg);
+int vg_set_mda_copies(struct volume_group *vg, uint32_t value);
 int vg_check_write_mode(struct volume_group *vg);
 #define vg_is_clustered(vg) (vg_status((vg)) & CLUSTERED)
 #define vg_is_exported(vg) (vg_status((vg)) & EXPORTED_VG)
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5c74893..a597f3c 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -989,6 +989,22 @@ static int _recalc_extents(uint32_t *extents, const char *desc1,
 	return 1;
 }
 
+uint32_t vg_mda_copies(const struct volume_group *vg)
+{
+	return vg->mda_copies;
+}
+
+int vg_set_mda_copies(struct volume_group *vg, uint32_t value)
+{
+	/* FIXME: add checks, etc, and set the value */
+	/*
+	 * FIXME: Before we set a larger value, we may need to
+	 * enable some mdas on PVS
+	 */
+	vg->mda_copies = value;
+	return 1;
+}
+
 int vg_set_extent_size(struct volume_group *vg, uint32_t new_size)
 {
 	uint32_t old_size = vg->extent_size;
-- 
1.6.0.6


