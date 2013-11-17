From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 17 Nov 2013 22:27:09 +0000 (UTC)
Subject: master - pv_label: NULL result is not always an internal error.
Message-ID: <20131117222709.2055660E9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=67c563ac2b643f97602686dc07cee4a8bdb5bc34
Commit:        67c563ac2b643f97602686dc07cee4a8bdb5bc34
Parent:        a8aa8d4b5c5722cab871c3243a203d26d6f5ac83
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Aug 21 01:30:38 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 17 21:43:06 2013 +0100

pv_label: NULL result is not always an internal error.

---
 lib/metadata/pv.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index 0288f07..1d608f2 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -355,7 +355,10 @@ struct label *pv_label(const struct physical_volume *pv)
 	struct lvmcache_info *info =
 		lvmcache_info_from_pvid((const char *)&pv->id.uuid, 0);
 	if (!info) {
-		log_error(INTERNAL_ERROR "PV %s unexpectedly not in cache.", dev_name(pv->dev));
+		if (pv->vg) /* process_each_pv will create PVs that are dummy
+			     * and that have no label associated */
+			log_error(INTERNAL_ERROR "PV %s unexpectedly not in cache.",
+				  dev_name(pv->dev));
 		return NULL;
 	}
 	return lvmcache_get_label(info);


