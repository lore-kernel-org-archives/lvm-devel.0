From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Sep 2010 17:06:28 -0400
Subject: [PATCH 16/20] Add pv_name_dup() and pv_fmt_dup() helper functions.
In-Reply-To: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
References: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1285189592-26525-17-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/pv.c |   12 ++++++++++++
 lib/metadata/pv.h |    2 ++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index 8b4dbf5..e4c73d3 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -21,6 +21,18 @@
  */
 #define pv_field(handle, field)	((handle)->field)
 
+char *pv_fmt_dup(const struct physical_volume *pv)
+{
+	if (!pv->fmt)
+		return NULL;
+	return dm_pool_strdup(pv->vg->vgmem, pv->fmt->name);
+}
+
+char *pv_name_dup(const struct physical_volume *pv)
+{
+	return dm_pool_strdup(pv->vg->vgmem, dev_name(pv->dev));
+}
+
 /*
  * Gets/Sets for external LVM library
  */
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index 295f811..0be1e23 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -52,6 +52,8 @@ struct physical_volume {
 	struct dm_list tags;
 };
 
+char *pv_fmt_dup(const struct physical_volume *pv);
+char *pv_name_dup(const struct physical_volume *pv);
 struct device *pv_dev(const struct physical_volume *pv);
 const char *pv_vg_name(const struct physical_volume *pv);
 char *pv_attr_dup(struct dm_pool *mem, const struct physical_volume *pv);
-- 
1.7.2.2


