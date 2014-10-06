From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:34 +0000 (UTC)
Subject: master - pool: validate_pool_chunk_size
Message-ID: <20141006133334.801E261041@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a2aa609810d7d0d6b8ff5b9fe8c6e1e13fbfbbac
Commit:        a2aa609810d7d0d6b8ff5b9fe8c6e1e13fbfbbac
Parent:        7783fe3e93b6fee0e8ea8198917b2d1a3072bdab
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 6 12:18:57 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:23:01 2014 +0200

pool: validate_pool_chunk_size

Introduce pool function for validation of chunk size.
It's good idea to be able to reject invalid chunk size
when entered on command line before we open VG.
---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/pool_manip.c        |   40 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3855bb1..875ab20 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Introduce single validation routine for pool chunk size.
   Support --yes like --force in vg/lvremove to skip y|n prompt.
   Support --yes with lvconvert --splitsnapshot.
   Fix detection of unsupported thin external lvconversions.
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index d04d987..b8e7415 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -731,6 +731,7 @@ int thin_pool_feature_supported(const struct logical_volume *pool_lv, int featur
 int recalculate_pool_chunk_size_with_dev_hints(struct logical_volume *pool_lv,
 					       int passed_args,
 					       int chunk_size_calc_policy);
+int validate_pool_chunk_size(struct cmd_context *cmd, const struct segment_type *segtype, uint32_t chunk_size);
 int update_pool_lv(struct logical_volume *lv, int activate);
 int update_pool_params(const struct segment_type *segtype,
 		       struct volume_group *vg, unsigned target_attr,
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 0c66c77..4621c57 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -232,6 +232,46 @@ struct lv_segment *find_pool_seg(const struct lv_segment *seg)
 	return pool_seg;
 }
 
+int validate_pool_chunk_size(struct cmd_context *cmd,
+			     const struct segment_type *segtype,
+			     uint32_t chunk_size)
+{
+	uint32_t min_size, max_size;
+	const char *name;
+	int r = 1;
+
+	if (segtype_is_cache(segtype) || segtype_is_cache_pool(segtype)) {
+		min_size = DM_CACHE_MIN_DATA_BLOCK_SIZE;
+		max_size = DM_CACHE_MAX_DATA_BLOCK_SIZE;
+		name = "Cache";
+	} else if (segtype_is_thin(segtype)) {
+		min_size = DM_THIN_MIN_DATA_BLOCK_SIZE;
+		max_size = DM_THIN_MAX_DATA_BLOCK_SIZE;
+		name = "Thin";
+	} else {
+		log_error(INTERNAL_ERROR "Cannot validate chunk size of "
+			  "%s segtype.", segtype->name);
+		return 0;
+	}
+
+	if ((chunk_size < min_size) || (chunk_size > max_size)) {
+		log_error("%s pool chunk size %s is not in the range %s to %s.",
+			  name, display_size(cmd, chunk_size),
+			  display_size(cmd, min_size),
+			  display_size(cmd, max_size));
+		r = 0;
+	}
+
+	if (chunk_size & (min_size - 1)) {
+		log_error("%s pool chunk size %s must be a multiple of %s.",
+			  name, display_size(cmd, chunk_size),
+			  display_size(cmd, min_size));
+		r = 0;
+	}
+
+	return r;
+}
+
 /* Greatest common divisor */
 static unsigned long _gcd(unsigned long n1, unsigned long n2)
 {


