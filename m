From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue, 13 Dec 2016 21:04:39 +0000 (UTC)
Subject: master - libdm: add min_num_bits to dm_bitset_parse_list()
Message-ID: <20161213210439.8957B603B3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7dff632c11e6ddce77dc9cde8f9011bb22970589
Commit:        7dff632c11e6ddce77dc9cde8f9011bb22970589
Parent:        e8d966bc31741f846dc6d0d4af9a565d19560b98
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Dec 11 22:41:45 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Dec 13 21:02:18 2016 +0000

libdm: add min_num_bits to dm_bitset_parse_list()

It's useful to be able to specify a minimum number of bits for a
new bitmap parsed from a list, for e.g. to allow for expansing a
group without needing to copy/reallocate the bitmap.

Add a backwards compatible symbol for programs linked against old
versions of the library.
---
 libdm/.exported_symbols.DM_1_02_138 |    1 +
 libdm/datastruct/bitset.c           |   22 +++++++++++++++++++++-
 libdm/libdevmapper.h                |    3 ++-
 libdm/libdm-stats.c                 |    5 +++--
 4 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/libdm/.exported_symbols.DM_1_02_138 b/libdm/.exported_symbols.DM_1_02_138
index 63fc2b8..7535829 100644
--- a/libdm/.exported_symbols.DM_1_02_138
+++ b/libdm/.exported_symbols.DM_1_02_138
@@ -1,2 +1,3 @@
 dm_bit_get_last
 dm_bit_get_prev
+dm_bitset_parse_list
diff --git a/libdm/datastruct/bitset.c b/libdm/datastruct/bitset.c
index 90efec6..b0826e1 100644
--- a/libdm/datastruct/bitset.c
+++ b/libdm/datastruct/bitset.c
@@ -145,7 +145,8 @@ int dm_bit_get_last(dm_bitset_t bs)
 /*
  * Based on the Linux kernel __bitmap_parselist from lib/bitmap.c
  */
-dm_bitset_t dm_bitset_parse_list(const char *str, struct dm_pool *mem)
+dm_bitset_t dm_bitset_parse_list(const char *str, struct dm_pool *mem,
+				 size_t min_num_bits)
 {
 	unsigned a, b;
 	int c, old_c, totaldigits, ndigits, nmaskbits;
@@ -221,6 +222,9 @@ scan:
 	} while (len && c == ',');
 
 	if (!mask) {
+		if (min_num_bits && (nmaskbits < min_num_bits))
+			nmaskbits = min_num_bits;
+
 		if (!(mask = dm_bitset_create(mem, nmaskbits)))
 			goto_bad;
 		str = start;
@@ -237,3 +241,19 @@ bad:
 	}
 	return NULL;
 }
+
+#if defined(__GNUC__)
+/*
+ * Maintain backward compatibility with older versions that did not
+ * accept a 'min_num_bits' argument to dm_bitset_parse_list().
+ */
+dm_bitset_t dm_bitset_parse_list_v1_02_129(const char *str, struct dm_pool *mem);
+dm_bitset_t dm_bitset_parse_list_v1_02_129(const char *str, struct dm_pool *mem)
+{
+	return dm_bitset_parse_list(str, mem, 0);
+}
+DM_EXPORT_SYMBOL(dm_bitset_parse_list, 1_02_129);
+
+#else /* if defined(__GNUC__) */
+
+#endif
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 44aa55c..bcf784b 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -2100,7 +2100,8 @@ int dm_bit_get_prev(dm_bitset_t bs, int last_bit);
  * dm_malloc(). Otherwise the bitset will be allocated using the supplied
  * dm_pool.
  */
-dm_bitset_t dm_bitset_parse_list(const char *str, struct dm_pool *mem);
+dm_bitset_t dm_bitset_parse_list(const char *str, struct dm_pool *mem,
+				 size_t min_num_bits);
 
 /* Returns number of set bits */
 static inline unsigned hweight32(uint32_t i)
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 8210a93..02a30dc 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -675,6 +675,7 @@ static void _check_group_regions_present(struct dm_stats *dms,
 #define DMS_GROUP_TAG_LEN (sizeof(DMS_GROUP_TAG) - 1)
 #define DMS_GROUP_SEP ':'
 #define DMS_AUX_SEP "#"
+
 static int _parse_aux_data_group(struct dm_stats *dms,
 				 struct dm_stats_region *region,
 				 struct dm_stats_group *group)
@@ -718,7 +719,7 @@ static int _parse_aux_data_group(struct dm_stats *dms,
 		end = c + strlen(c);
 	*(end++) = '\0';
 
-	if (!(regions = dm_bitset_parse_list(c, NULL))) {
+	if (!(regions = dm_bitset_parse_list(c, NULL, 0))) {
 		log_error("Could not parse member list while "
 			  "reading group aux_data");
 		return 0;
@@ -3992,7 +3993,7 @@ int dm_stats_create_group(struct dm_stats *dms, const char *members,
 		return 0;
 	};
 
-	if (!(regions = dm_bitset_parse_list(members, NULL))) {
+	if (!(regions = dm_bitset_parse_list(members, NULL, 0))) {
 		log_error("Could not parse list: '%s'", members);
 		return 0;
 	}


