From: Petr Rockai <prockai@redhat.com>
Date: Mon, 29 Jul 2013 21:19:17 +0200
Subject: [PATCH 13/20] metadata: Add a pv_label accessor (go from a PV to its label).
In-Reply-To: <1375125564-1188-1-git-send-email-prockai@redhat.com>
References: <1375125564-1188-1-git-send-email-prockai@redhat.com>
Message-ID: <1375125564-1188-13-git-send-email-prockai@redhat.com>
	(sfid-20130729_211929_516430_F3716442)
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 lib/metadata/pv.c | 10 ++++++++++
 lib/metadata/pv.h |  1 +
 2 files changed, 11 insertions(+)

diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index 5b08998..0288f07 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -350,3 +350,13 @@ unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned mda_ignor
 	return 1;
 }
 
+struct label *pv_label(const struct physical_volume *pv)
+{
+	struct lvmcache_info *info =
+		lvmcache_info_from_pvid((const char *)&pv->id.uuid, 0);
+	if (!info) {
+		log_error(INTERNAL_ERROR "PV %s unexpectedly not in cache.", dev_name(pv->dev));
+		return NULL;
+	}
+	return lvmcache_get_label(info);
+}
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index ff708f8..8fd3061 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -95,5 +95,6 @@ unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned ignored);
 int is_orphan(const struct physical_volume *pv);
 int is_missing_pv(const struct physical_volume *pv);
 int is_pv(const struct physical_volume *pv);
+struct label *pv_label(const struct physical_volume *pv);
 
 #endif /* _LVM_PV_H */
-- 
1.8.2


