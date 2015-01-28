From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 28 Jan 2015 12:45:57 +0000 (UTC)
Subject: master - raid: lock holder will skip visible raid LVs
Message-ID: <20150128124557.1FB6660314@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=553f37da71fecd167fd97b26a33c341b8cba485a
Commit:        553f37da71fecd167fd97b26a33c341b8cba485a
Parent:        93b90157605f557cd4b0e48c38e6f290eaa871b1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 28 13:34:41 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 28 13:45:27 2015 +0100

raid: lock holder will skip visible raid LVs

RAID marks legs as VISIBLE with notion it's not longer
true raid leg - so skip tree scannig and take this LV
as top-level LV.
---
 lib/metadata/lv.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 683ec47..9052e63 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1018,6 +1018,10 @@ const struct logical_volume *lv_lock_holder(const struct logical_volume *lv)
 				return sl->seg->lv;
 			}
 
+	/* RAID changes visibility of splitted LVs but references them still as leg/meta */
+	if ((lv_is_raid_image(lv) || lv_is_raid_metadata(lv)) && lv_is_visible(lv))
+		return lv;
+
 	/* For other types, by default look for the first user */
 	dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
 		/* FIXME: complete this exception list */


