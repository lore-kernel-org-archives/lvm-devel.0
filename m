From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 13 Jan 2016 16:12:28 +0000 (UTC)
Subject: master - lv: fix check for NULL origin_lv in _do_lv_origin_dup, cleanup _do_lvconvert_lv_dup
Message-ID: <20160113161228.60E4960A3E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=63d59254d95e29a4e6ca47cadfb15cf821ec7479
Commit:        63d59254d95e29a4e6ca47cadfb15cf821ec7479
Parent:        04d1a8a5e41bd9fbcaa885b0b13faba85db532d9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jan 13 17:11:00 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 13 17:11:05 2016 +0100

lv: fix check for NULL origin_lv in _do_lv_origin_dup, cleanup _do_lvconvert_lv_dup

---
 lib/metadata/lv.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 96f6f5c..6575cc9 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -273,7 +273,7 @@ static char *_do_lv_origin_dup(struct dm_pool *mem, const struct logical_volume
 {
 	struct logical_volume *origin_lv = lv_origin_lv(lv);
 
-	if (!lv)
+	if (!origin_lv)
 		return NULL;
 
 	if (uuid)
@@ -533,14 +533,13 @@ static char *_do_lv_convert_lv_dup(struct dm_pool *mem, const struct logical_vol
 {
 	struct logical_volume *convert_lv = lv_convert_lv(lv);
 
-	if (convert_lv) {
-		if (uuid)
-			return lv_uuid_dup(mem, convert_lv);
-		else
-			return lv_name_dup(mem, convert_lv);
-	}
+	if (!convert_lv)
+		return NULL;
 
-	return NULL;
+	if (uuid)
+		return lv_uuid_dup(mem, convert_lv);
+	else
+		return lv_name_dup(mem, convert_lv);
 }
 
 char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)


