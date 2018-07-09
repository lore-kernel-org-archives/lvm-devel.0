From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:34:44 -0400
Subject: master - vdo: support functions to map enums to string names
Message-ID: <201807091334.w69DYihG030674@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aa63dfbe39860f04d8965e2afc4959cd20988411
Commit:        aa63dfbe39860f04d8965e2afc4959cd20988411
Parent:        aff69ecf396a858d684cd3e54baea131e229f5a2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 2 21:58:18 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:28:35 2018 +0200

vdo: support functions to map enums to string names

Translate VDO enums to printable strings.
---
 lib/metadata/metadata-exported.h |    3 ++
 lib/metadata/vdo_manip.c         |   50 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 53 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index f5b540a..b221139 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1251,6 +1251,9 @@ int wipe_cache_pool(struct logical_volume *cache_pool_lv);
 
 /* ++  metadata/vdo_manip.c */
 
+const char *get_vdo_compression_state_name(enum dm_vdo_compression_state state);
+const char *get_vdo_index_state_name(enum dm_vdo_index_state state);
+const char *get_vdo_operating_mode_name(enum dm_vdo_operating_mode mode);
 uint64_t get_vdo_pool_virtual_size(const struct lv_segment *vdo_pool_seg);
 struct logical_volume *convert_vdo_pool_lv(struct logical_volume *data_lv,
 					   const struct dm_vdo_target_params *vtp,
diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index 451c8bd..8aee3dc 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -25,6 +25,56 @@
 #include "lib/misc/lvm-signal.h"
 #include "lib/misc/lvm-exec.h"
 
+const char *get_vdo_compression_state_name(enum dm_vdo_compression_state state)
+{
+	switch (state) {
+	case DM_VDO_COMPRESSION_ONLINE:
+		return "online";
+	default:
+		log_debug(INTERNAL_ERROR "Unrecognized compression state: %u.", state);
+		/* Fall through */
+	case DM_VDO_COMPRESSION_OFFLINE:
+		return "offline";
+	}
+}
+
+const char *get_vdo_index_state_name(enum dm_vdo_index_state state)
+{
+	switch (state) {
+	case DM_VDO_INDEX_ERROR:
+		return "error";
+	case DM_VDO_INDEX_CLOSED:
+		return "closed";
+	case DM_VDO_INDEX_OPENING:
+		return "opening";
+	case DM_VDO_INDEX_CLOSING:
+		return "closing";
+	case DM_VDO_INDEX_OFFLINE:
+		return "offline";
+	case DM_VDO_INDEX_ONLINE:
+		return "online";
+	default:
+		log_debug(INTERNAL_ERROR "Unrecognized index state: %u.", state);
+		/* Fall through */
+	case DM_VDO_INDEX_UNKNOWN:
+		return "unknown";
+	}
+}
+
+const char *get_vdo_operating_mode_name(enum dm_vdo_operating_mode mode)
+{
+	switch (mode) {
+	case DM_VDO_MODE_RECOVERING:
+		return "recovering";
+	case DM_VDO_MODE_READ_ONLY:
+		return "read-only";
+	default:
+		log_debug(INTERNAL_ERROR "Unrecognized operating mode: %u.", mode);
+		/* Fall through */
+	case DM_VDO_MODE_NORMAL:
+		return "normal";
+	}
+}
 
 /*
  * Size of VDO virtual LV is adding header_size in front and back of device


