From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:08:21 +0000 (UTC)
Subject: master - pv: add is_used_pv fn
Message-ID: <20160215120821.6086660DC7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4cbaaa5c98c78784e9eab5489c12d2e72e952f32
Commit:        4cbaaa5c98c78784e9eab5489c12d2e72e952f32
Parent:        71ea2e1602f9b058ee1cad445a07bf80413f833f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 12 10:17:18 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 12:44:46 2016 +0100

pv: add is_used_pv fn

---
 lib/metadata/pv.c |   21 +++++++++++++++++++++
 lib/metadata/pv.h |    1 +
 2 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index 927b426..7ea7d2b 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -208,6 +208,27 @@ int is_missing_pv(const struct physical_volume *pv)
 	return pv_field(pv, status) & MISSING_PV ? 1 : 0;
 }
 
+int is_used_pv(const struct physical_volume *pv)
+{
+	struct lvmcache_info *info;
+	uint32_t ext_flags;
+
+	if (!is_orphan(pv))
+		return 1;
+
+	if (!(pv->fmt->features & FMT_PV_FLAGS))
+		return 0;
+
+	if (!(info = lvmcache_info_from_pvid((const char *)&pv->id, 0))) {
+		log_error("Failed to find cached info for PV %s.", pv_dev_name(pv));
+		return -1;
+	}
+
+	ext_flags = lvmcache_ext_flags(info);
+
+	return ext_flags & PV_EXT_USED ? 1 : 0;
+}
+
 char *pv_attr_dup(struct dm_pool *mem, const struct physical_volume *pv)
 {
 	char *repstr;
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index cbfe79c..9e8207d 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -96,6 +96,7 @@ uint32_t pv_mda_used_count(const struct physical_volume *pv);
 unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned ignored);
 int is_orphan(const struct physical_volume *pv);
 int is_missing_pv(const struct physical_volume *pv);
+int is_used_pv(const struct physical_volume *pv);
 int is_pv(const struct physical_volume *pv);
 struct label *pv_label(const struct physical_volume *pv);
 


