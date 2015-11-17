From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Nov 2015 18:01:42 +0000 (UTC)
Subject: master - cleanup: add some test for NULL
Message-ID: <20151117180142.45434600C1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d8049dd17a50b704edea69c968305aee732cb256
Commit:        d8049dd17a50b704edea69c968305aee732cb256
Parent:        011dd82050fb3225d7ea3c24be5c8dad026117d3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 17 13:21:22 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 17 19:01:25 2015 +0100

cleanup: add some test for NULL

Coverity here is a bit 'blind' here and cannot resolve which
code paths are actually able to hit this code path.
(It's using 'statistic' to resolve all possible paths,
and it's not scanning 'individual' code paths.)

This just cleans warns and add 'cheap' tests.
---
 lib/metadata/metadata.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index fa166e4..77bbeab 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2254,7 +2254,7 @@ static int _lv_postorder_cleanup(struct logical_volume *lv, void *data)
 static int _lv_postorder_level(struct logical_volume *lv, void *data)
 {
 	struct _lv_postorder_baton *baton = data;
-	return _lv_postorder_visit(lv, baton->fn, baton->data);
+	return (data) ? _lv_postorder_visit(lv, baton->fn, baton->data) : 0;
 };
 
 static int _lv_postorder_visit(struct logical_volume *lv,
@@ -2346,7 +2346,7 @@ struct _lv_mark_if_partial_baton {
 static int _lv_mark_if_partial_collect(struct logical_volume *lv, void *data)
 {
 	struct _lv_mark_if_partial_baton *baton = data;
-	if (lv->status & PARTIAL_LV)
+	if (baton && lv->status & PARTIAL_LV)
 		baton->partial = 1;
 
 	return 1;


