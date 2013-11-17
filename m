From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 17 Nov 2013 22:27:21 +0000 (UTC)
Subject: master - metadata: Do not throw an error in pv_label for missing PVs.
Message-ID: <20131117222721.93DE661327@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ecc296311ff2a251aa254353b0a0fb3ee97be97c
Commit:        ecc296311ff2a251aa254353b0a0fb3ee97be97c
Parent:        a5bb1b48eea704c5970a719d2e77577dccd82bb9
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Nov 17 22:35:16 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 17 22:35:16 2013 +0100

metadata: Do not throw an error in pv_label for missing PVs.

---
 lib/metadata/pv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index 1d608f2..349048e 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -355,7 +355,7 @@ struct label *pv_label(const struct physical_volume *pv)
 	struct lvmcache_info *info =
 		lvmcache_info_from_pvid((const char *)&pv->id.uuid, 0);
 	if (!info) {
-		if (pv->vg) /* process_each_pv will create PVs that are dummy
+		if (pv->vg && pv->dev) /* process_each_pv will create PVs that are dummy
 			     * and that have no label associated */
 			log_error(INTERNAL_ERROR "PV %s unexpectedly not in cache.",
 				  dev_name(pv->dev));


