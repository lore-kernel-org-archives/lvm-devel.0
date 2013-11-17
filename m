From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 17 Nov 2013 22:26:52 +0000 (UTC)
Subject: master - metadata: Add a pv_label accessor (go from a PV to its label).
Message-ID: <20131117222652.6C6536103A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dc3a0711454938e1a6264b7e3bf24a6dd1ac7e9f
Commit:        dc3a0711454938e1a6264b7e3bf24a6dd1ac7e9f
Parent:        a2034e9a99337ac16ee415f7f2398e0b8e976716
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jul 29 18:54:59 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 17 21:41:27 2013 +0100

metadata: Add a pv_label accessor (go from a PV to its label).

---
 lib/metadata/pv.c |   10 ++++++++++
 lib/metadata/pv.h |    1 +
 2 files changed, 11 insertions(+), 0 deletions(-)

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


