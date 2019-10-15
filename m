From: David Teigland <teigland@sourceware.org>
Date: Tue, 15 Oct 2019 15:36:24 -0400
Subject: master - cache: change cachevol flags for backward compat
Message-ID: <201910151936.x9FJaOO3008315@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=91ee025d5bf5188c3519a674eaa28769a8922a18
Commit:        91ee025d5bf5188c3519a674eaa28769a8922a18
Parent:        6666c3934631eddebe0c00125d9df8517bc3da9a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 14 15:32:13 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Oct 15 09:05:52 2019 -0500

cache: change cachevol flags for backward compat

A cachevol LV had the CACHE_VOL status flag in metadata,
and the cache LV using it had no new flag.  This caused
problems if the new metadata was used by an old version
of lvm.  An old version of lvm would have two problems
processing the new metadata:

. The old lvm would return an error when reading the VG
  metadata when it saw the unknown CACHE_VOL status flag.

. The old lvm would return an error when reading the VG
  metadata because it would not find an expected cache pool
  attached to the cache LV (since the cache LV had a
  cachevol attached instead.)

Change the use of flags:

. Change the CACHE_VOL flag to be a COMPATIBLE flag (instead
  of a STATUS flag) so that old versions will not fail when
  they see it.

. When a cache LV is using a cachevol, the cache LV gets
  a new SEGTYPE flag CACHE_USES_CACHEVOL.  This flag is
  appended to the segtype name, so that old lvm versions
  will fail to use the LV because of an unknown segtype,
  as opposed to failing to read the VG.
---
 lib/format_text/flags.c          |   14 ++++++++++++--
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/pool_manip.c        |    1 +
 tools/lvconvert.c                |   10 ++++++++++
 4 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 1ae64a2..2873ba6 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -72,7 +72,8 @@ static const struct flag _lv_flags[] = {
 	{LV_ACTIVATION_SKIP, "ACTIVATION_SKIP", COMPATIBLE_FLAG},
 	{LV_ERROR_WHEN_FULL, "ERROR_WHEN_FULL", COMPATIBLE_FLAG},
 	{LV_METADATA_FORMAT, "METADATA_FORMAT", SEGTYPE_FLAG},
-	{LV_CACHE_VOL, "CACHE_VOL", STATUS_FLAG},
+	{LV_CACHE_VOL, "CACHE_VOL", COMPATIBLE_FLAG},
+	{LV_CACHE_USES_CACHEVOL, "CACHE_USES_CACHEVOL", SEGTYPE_FLAG},
 	{LV_NOSCAN, NULL, 0},
 	{LV_TEMPORARY, NULL, 0},
 	{POOL_METADATA_SPARE, NULL, 0},
@@ -192,12 +193,21 @@ int read_flags(uint64_t *status, enum pv_vg_lv_e type, int mask, const struct dm
 			return 0;
 		}
 
-		for (f = 0; flags[f].description; f++)
+		/*
+		 * For a short time CACHE_VOL was a STATUS_FLAG, then it
+		 * was changed to COMPATIBLE_FLAG, so we want to read it
+		 * from either place.
+		 */
+		if (type == LV_FLAGS && !strcmp(cv->v.str, "CACHE_VOL"))
+			mask = (STATUS_FLAG | COMPATIBLE_FLAG);
+
+		for (f = 0; flags[f].description; f++) {
 			if ((flags[f].kind & mask) &&
 			    !strcmp(flags[f].description, cv->v.str)) {
 				s |= flags[f].mask;
 				break;
 			}
+		}
 
 		if (type == VG_FLAGS && !strcmp(cv->v.str, "PARTIAL")) {
 			/*
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 2d97753..66d8579 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -153,6 +153,7 @@
 #define LV_VDO_POOL_DATA	UINT64_C(0x8000000000000000)    /* LV - Internal user only */
 
 #define LV_CACHE_VOL		UINT64_C(0x0010000000000000)	/* LV - also a PV flag */
+#define LV_CACHE_USES_CACHEVOL	UINT64_C(0x4000000000000000)	/* LV - also a PV flag */
 
 
 /* Format features flags */
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index b9d04ea..8d0aa83 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -253,6 +253,7 @@ int detach_pool_lv(struct lv_segment *seg)
 		if (!remove_seg_from_segs_using_this_lv(seg->pool_lv, seg))
 			return_0;
 		seg->lv->status &= ~CACHE;
+		seg->lv->status &= ~LV_CACHE_USES_CACHEVOL;
 		lv_set_visible(seg->pool_lv);
 		seg->pool_lv->status &= ~LV_CACHE_VOL;
 		seg->pool_lv = NULL;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 3fa1b04..9ab362b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4267,7 +4267,17 @@ static int _lvconvert_cachevol_attach_single(struct cmd_context *cmd,
 	if (!lv_rename_update(cmd, cachevol_lv, cvol_name, 0))
 		return_0;
 
+	/*
+	 * This flag is added to the segtype name so that old versions of lvm
+	 * (if they happen to be used with new metadata with a cache LV using a
+	 * cachevol) will report an error when they see the unknown
+	 * cache+CACHE_USES_CACHEVOL segment type.  Otherwise the old version
+	 * would expect to find a cache pool and fail.
+	 */
+	lv->status |= LV_CACHE_USES_CACHEVOL;
+
 	cachevol_lv->status |= LV_CACHE_VOL;
+
 	if (!_cache_vol_attach(cmd, lv, cachevol_lv))
 		goto_out;
 


