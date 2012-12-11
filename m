From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Dec 2012 10:56:46 +0000 (UTC)
Subject: master - lvmetad: use dm_config_destroy to free pvmeta
Message-ID: <20121211105646.782FF40BD@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ff5c1c576c9f0162e9d82becfe30b100fc601c88
Commit:        ff5c1c576c9f0162e9d82becfe30b100fc601c88
Parent:        17be6d521008f4433dc4dc76464af9f993491745
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Dec 10 14:24:55 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 11 11:55:12 2012 +0100

lvmetad: use dm_config_destroy to free pvmeta

Release pvmeta handler with proper dm_config_destroy() function.
TODO: Fix primary fault for this internal error.

Signed-off-by: mcsontos at redhat.com
---
 lib/cache/lvmetad.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 72e07fd..e5c5f51 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -726,7 +726,7 @@ int lvmetad_pv_found(const struct id *pvid, struct device *device, const struct
 	} else {
 		if (handler) {
 			log_error(INTERNAL_ERROR "Handler needs existing VG.");
-			dm_free(pvmeta);
+			dm_config_destroy(pvmeta);
 			return 0;
 		}
 		/* There are no MDAs on this PV. */


