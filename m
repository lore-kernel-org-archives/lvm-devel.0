From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:42:34 +0000 (UTC)
Subject: master - cleanup: uint64_t casts
Message-ID: <20120823124234.7B1ACA33BE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bd67a3151aa3a3202d52fcc9ffac781b96dca04a
Commit:        bd67a3151aa3a3202d52fcc9ffac781b96dca04a
Parent:        ff86c6ed00859a93b984ffd5944c6ba3e450c747
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 16 20:07:30 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:37:21 2012 +0200

cleanup: uint64_t casts

---
 lib/format1/disk-rep.c     |    2 +-
 lib/format1/layout.c       |    2 +-
 lib/format1/lvm1-label.c   |    2 +-
 lib/format_pool/disk_rep.c |    2 +-
 lib/metadata/lv_manip.c    |    2 +-
 tools/pvdisplay.c          |    2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/format1/disk-rep.c b/lib/format1/disk-rep.c
index d7c3f7d..0143ea0 100644
--- a/lib/format1/disk-rep.c
+++ b/lib/format1/disk-rep.c
@@ -335,7 +335,7 @@ static void __update_lvmcache(const struct format_type *fmt,
 		return;
 	}
 
-	lvmcache_set_device_size(info, xlate32(dl->pvd.pv_size) << SECTOR_SHIFT);
+	lvmcache_set_device_size(info, ((uint64_t)xlate32(dl->pvd.pv_size)) << SECTOR_SHIFT);
 	lvmcache_del_mdas(info);
 	lvmcache_make_valid(info);
 }
diff --git a/lib/format1/layout.c b/lib/format1/layout.c
index de9b206..14a7eaf 100644
--- a/lib/format1/layout.c
+++ b/lib/format1/layout.c
@@ -153,7 +153,7 @@ int calculate_extent_count(struct physical_volume *pv, uint32_t extent_size,
 
 		pvd->pe_start = _round_up(end, LVM1_PE_ALIGN);
 
-	} while ((pvd->pe_start + (pvd->pe_total * extent_size))
+	} while ((pvd->pe_start + ((uint64_t)pvd->pe_total * extent_size))
 		 > pv->size);
 
 	if (pvd->pe_total > MAX_PE_TOTAL) {
diff --git a/lib/format1/lvm1-label.c b/lib/format1/lvm1-label.c
index 4c157ac..6138a05 100644
--- a/lib/format1/lvm1-label.c
+++ b/lib/format1/lvm1-label.c
@@ -79,7 +79,7 @@ static int _lvm1_read(struct labeller *l, struct device *dev, void *buf,
 		return_0;
 	*label = lvmcache_get_label(info);
 
-	lvmcache_set_device_size(info, xlate32(pvd->pv_size) << SECTOR_SHIFT);
+	lvmcache_set_device_size(info, ((uint64_t)xlate32(pvd->pv_size)) << SECTOR_SHIFT);
 	lvmcache_del_mdas(info);
 	lvmcache_make_valid(info);
 
diff --git a/lib/format_pool/disk_rep.c b/lib/format_pool/disk_rep.c
index 2201ab9..a140384 100644
--- a/lib/format_pool/disk_rep.c
+++ b/lib/format_pool/disk_rep.c
@@ -103,7 +103,7 @@ int read_pool_label(struct pool_list *pl, struct labeller *l,
 	if (label)
 		*label = lvmcache_get_label(info);
 
-	lvmcache_set_device_size(info, xlate32_be(pd->pl_blocks) << SECTOR_SHIFT);
+	lvmcache_set_device_size(info, ((uint64_t)xlate32_be(pd->pl_blocks)) << SECTOR_SHIFT);
 	lvmcache_del_mdas(info);
 	lvmcache_make_valid(info);
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 70b984e..51abae0 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -726,7 +726,7 @@ static uint32_t mirror_log_extents(uint32_t region_size, uint32_t pe_size, uint3
 {
 	size_t area_size, bitset_size, log_size, region_count;
 
-	area_size = area_len * pe_size;
+	area_size = (size_t)area_len * pe_size;
 	region_count = dm_div_up(area_size, region_size);
 
 	/* Work out how many "unsigned long"s we need to hold the bitset. */
diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index 2136721..c6cd412 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -54,7 +54,7 @@ static int _pvdisplay_single(struct cmd_context *cmd,
 	if (is_orphan(pv))
 		size = pv_size(pv);
 	else
-		size = (pv_pe_count(pv) - pv_pe_alloc_count(pv)) *
+		size = (uint64_t)(pv_pe_count(pv) - pv_pe_alloc_count(pv)) *
 			pv_pe_size(pv);
 
 	if (arg_count(cmd, short_ARG)) {


