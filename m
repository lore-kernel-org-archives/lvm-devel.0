From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 17 Nov 2013 22:26:50 +0000 (UTC)
Subject: master - metadata: Add lvmcache_info_mda_free as a companion to pv_mda_free.
Message-ID: <20131117222650.583106103A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a2034e9a99337ac16ee415f7f2398e0b8e976716
Commit:        a2034e9a99337ac16ee415f7f2398e0b8e976716
Parent:        1ef2c3c4ee325dd9ce607b62c1720d782021d399
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jul 29 18:52:28 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 17 21:41:27 2013 +0100

metadata: Add lvmcache_info_mda_free as a companion to pv_mda_free.

---
 lib/metadata/pv.c |   16 +++++++++++-----
 lib/metadata/pv.h |    2 ++
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index dad747c..5b08998 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -241,14 +241,11 @@ static int _pv_mda_free(struct metadata_area *mda, void *baton) {
 	return 1;
 }
 
-uint64_t pv_mda_free(const struct physical_volume *pv)
+uint64_t lvmcache_info_mda_free(struct lvmcache_info *info)
 {
-	struct lvmcache_info *info;
 	uint64_t freespace = UINT64_MAX;
-	const char *pvid = (const char *)&pv->id.uuid;
 
-	if ((info = lvmcache_info_from_pvid(pvid, 0)))
-		lvmcache_foreach_mda(info, _pv_mda_free, &freespace);
+	lvmcache_foreach_mda(info, _pv_mda_free, &freespace);
 
 	if (freespace == UINT64_MAX)
 		freespace = UINT64_C(0);
@@ -256,6 +253,15 @@ uint64_t pv_mda_free(const struct physical_volume *pv)
 	return freespace;
 }
 
+uint64_t pv_mda_free(const struct physical_volume *pv)
+{
+	const char *pvid = (const char *)&pv->id.uuid;
+	struct lvmcache_info *info;
+	if ((info = lvmcache_info_from_pvid(pvid, 0)))
+		return lvmcache_info_mda_free(info);
+	return 0;
+}
+
 uint64_t pv_used(const struct physical_volume *pv)
 {
 	uint64_t used;
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index c018f38..ff708f8 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -85,6 +85,8 @@ uint64_t pv_ba_size(const struct physical_volume *pv);
 uint32_t pv_pe_count(const struct physical_volume *pv);
 uint32_t pv_pe_alloc_count(const struct physical_volume *pv);
 uint64_t pv_mda_size(const struct physical_volume *pv);
+struct lvmcache_info;
+uint64_t lvmcache_info_mda_free(struct lvmcache_info *info);
 uint64_t pv_mda_free(const struct physical_volume *pv);
 uint64_t pv_used(const struct physical_volume *pv);
 uint32_t pv_mda_count(const struct physical_volume *pv);


