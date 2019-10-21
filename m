From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Oct 2019 09:33:27 -0400
Subject: master - gcc: older compiler is happier with this initilizer
Message-ID: <201910211333.x9LDXRTB019629@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f61d828c86d2b6466224290b9a1ffdaa16419f3d
Commit:        f61d828c86d2b6466224290b9a1ffdaa16419f3d
Parent:        a0e40bad1d7c2a93d0dfd9ad27542673ee5300a5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 21 12:24:40 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 21 15:32:35 2019 +0200

gcc: older compiler is happier with this initilizer

---
 lib/activate/dev_manager.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 9e4dba4..a2e9039 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2372,7 +2372,7 @@ static int _add_cvol_subdev_to_dtree(struct dev_manager *dm, struct dm_tree *dtr
 	struct lv_segment *lvseg = first_seg(lv);
 	struct dm_info info;
 	char *name ,*dlid;
-	union lvid lvid = { 0 };
+	union lvid lvid = { { { "" } } };
 
 	memcpy(&lvid.id[0], &lv->vg->id, sizeof(struct id));
 	/* When ID is provided in form of metadata_id or data_id, otherwise use CVOL ID */


