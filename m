From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 10 Feb 2010 15:55:42 +0100
Subject: [PATCH 3/6] Clean gcc const warning
In-Reply-To: <cover.1265812946.git.zkabelac@redhat.com>
References: <cover.1265812946.git.zkabelac@redhat.com>
Message-ID: <8e90ab28e6e1653b24c69d57726337379f40b09b.1265812946.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/report/report.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 2cceedd..cf037cb 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -66,7 +66,7 @@ static int _dev_name_disp(struct dm_report *rh, struct dm_pool *mem __attribute(
 			  struct dm_report_field *field,
 			  const void *data, void *private __attribute((unused)))
 {
-	const char *name = dev_name(*(const struct device **) data);
+	const char *name = dev_name(*(const struct device * const *) data);
 
 	return dm_report_field_string(rh, field, &name);
 }
@@ -795,7 +795,7 @@ static int _devsize_disp(struct dm_report *rh, struct dm_pool *mem,
 			 struct dm_report_field *field,
 			 const void *data, void *private)
 {
-	const struct device *dev = *(const struct device **) data;
+	const struct device *dev = *(const struct device * const *) data;
 	uint64_t size;
 
 	if (!dev_get_size(dev, &size))
@@ -879,7 +879,7 @@ static int _pvmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	struct lvmcache_info *info;
 	uint64_t freespace = UINT64_MAX, mda_free;
-	const char *pvid = (const char *)(&((struct id *) data)->uuid);
+	const char *pvid = (const char *)(&((const struct id *) data)->uuid);
 	struct metadata_area *mda;
 
 	if ((info = info_from_pvid(pvid, 0)))
@@ -922,7 +922,7 @@ static int _pvmdasize_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	struct lvmcache_info *info;
 	uint64_t min_mda_size = 0;
-	const char *pvid = (const char *)(&((struct id *) data)->uuid);
+	const char *pvid = (const char *)(&((const struct id *) data)->uuid);
 
 	/* PVs could have 2 mdas of different sizes (rounding effect) */
 	if ((info = info_from_pvid(pvid, 0)))
-- 
1.6.6.1


