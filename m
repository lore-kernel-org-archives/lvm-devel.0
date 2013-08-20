From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 20 Aug 2013 23:36:11 +0000 (UTC)
Subject: dev-dct-process-part3 - pv_label: NULL result is not always an internal error.
Message-ID: <20130820233611.9666260DE5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=53516ea789b8b8f71ac84468f38ce9a0c40f9649
Commit:        53516ea789b8b8f71ac84468f38ce9a0c40f9649
Parent:        940aeee4e7e86f4f389dd20cdd82826c7eeb470c
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Aug 21 01:30:38 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Aug 21 01:30:38 2013 +0200

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


