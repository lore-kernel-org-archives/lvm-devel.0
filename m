From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  9 Dec 2016 14:15:21 +0000 (UTC)
Subject: master - cleanup: zero baton in struct initilizer
Message-ID: <20161209141521.C3929602B6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c5aeb210155eff180ad5f1127ed451307bd7b854
Commit:        c5aeb210155eff180ad5f1127ed451307bd7b854
Parent:        f9c6c115d3cfd203e99561d500293dbfc8662f49
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 9 15:08:04 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 9 15:15:02 2016 +0100

cleanup: zero baton in struct initilizer

---
 lib/metadata/metadata.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ad6cb2a..c636fe2 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2544,7 +2544,7 @@ static int _lv_mark_if_partial_collect(struct logical_volume *lv, void *data)
 static int _lv_mark_if_partial_single(struct logical_volume *lv, void *data)
 {
 	unsigned s;
-	struct _lv_mark_if_partial_baton baton;
+	struct _lv_mark_if_partial_baton baton = { .partial = 0 };
 	struct lv_segment *lvseg;
 
 	dm_list_iterate_items(lvseg, &lv->segments) {
@@ -2556,7 +2556,6 @@ static int _lv_mark_if_partial_single(struct logical_volume *lv, void *data)
 		}
 	}
 
-	baton.partial = 0;
 	if (!_lv_each_dependency(lv, _lv_mark_if_partial_collect, &baton))
 		return_0;
 


