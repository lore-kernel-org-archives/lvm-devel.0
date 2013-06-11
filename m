From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Jun 2013 12:08:53 +0000 (UTC)
Subject: master - cleanup: remove {}
Message-ID: <20130611120853.7D6BE610D8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1dcba13dfcccfb043f49708ca8f44c4d9fa9a260
Commit:        1dcba13dfcccfb043f49708ca8f44c4d9fa9a260
Parent:        d0def236d636d2f4d9d0a08878d19a59891fa963
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 11 13:45:36 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 11 13:55:26 2013 +0200

cleanup: remove {}

---
 lib/metadata/lv.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index b47b096..182eb57 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -556,9 +556,9 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 		repstr[0] = (_lv_raid_image_in_sync(lv)) ? 'i' : 'I';
 	else if (lv->status & MIRROR_LOG)
 		repstr[0] = 'l';
-	else if (lv_is_cow(lv)) {
+	else if (lv_is_cow(lv))
 		repstr[0] = (lv_is_merging_cow(lv)) ? 'S' : 's';
-	} else
+	else
 		repstr[0] = '-';
 
 	if (lv->status & PVMOVE)


