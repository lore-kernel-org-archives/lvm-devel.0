From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 4 Oct 2019 11:33:26 -0400
Subject: master - vdo: introduce get_vdo_write_policy_name
Message-ID: <201910041533.x94FXQqH031048@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cf8aee096f2064fb8d8421f73807ad98746bc7c6
Commit:        cf8aee096f2064fb8d8421f73807ad98746bc7c6
Parent:        c756f7680202f0a59dea917527e95f68c7a9af4b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 4 14:59:00 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 4 17:31:55 2019 +0200

vdo: introduce get_vdo_write_policy_name

---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/vdo_manip.c         |   15 +++++++++++++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 081e9a5..71e4c77 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1301,6 +1301,7 @@ struct lv_status_vdo {
 const char *get_vdo_compression_state_name(enum dm_vdo_compression_state state);
 const char *get_vdo_index_state_name(enum dm_vdo_index_state state);
 const char *get_vdo_operating_mode_name(enum dm_vdo_operating_mode mode);
+const char *get_vdo_write_policy_name(enum dm_vdo_write_policy policy);
 uint64_t get_vdo_pool_virtual_size(const struct lv_segment *vdo_pool_seg);
 int update_vdo_pool_virtual_size(struct lv_segment *vdo_pool_seg);
 int parse_vdo_pool_status(struct dm_pool *mem, const struct logical_volume *vdo_pool_lv,
diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index 7ed3ef9..26694cc 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -74,6 +74,21 @@ const char *get_vdo_operating_mode_name(enum dm_vdo_operating_mode mode)
 	}
 }
 
+const char *get_vdo_write_policy_name(enum dm_vdo_write_policy policy)
+{
+	switch (policy) {
+	case DM_VDO_WRITE_POLICY_SYNC:
+		return "sync";
+	case DM_VDO_WRITE_POLICY_ASYNC:
+		return "async";
+	default:
+		log_debug(INTERNAL_ERROR "Unrecognized VDO write policy: %u.", policy);
+		/* Fall through */
+	case DM_VDO_WRITE_POLICY_AUTO:
+		return "auto";
+	}
+}
+
 /*
  * Size of VDO virtual LV is adding header_size in front and back of device
  * to avoid colission with blkid checks.


