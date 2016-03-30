From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 30 Mar 2016 13:58:31 +0000 (UTC)
Subject: master - dev-cache: fix check for already indexed dev in _index_dev_by_vgid_and_lvid
Message-ID: <20160330135831.D3BE260284@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9a086a660772fbe8e0baa5717db94982f5015137
Commit:        9a086a660772fbe8e0baa5717db94982f5015137
Parent:        06ef7ba8765d64044b008a33f1c1faeac6112a4a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Mar 30 14:35:06 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 30 15:57:57 2016 +0200

dev-cache: fix check for already indexed dev in _index_dev_by_vgid_and_lvid

---
 lib/device/dev-cache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 50ef2f2..12d0d56 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -529,7 +529,7 @@ static int _index_dev_by_vgid_and_lvid(struct device *dev)
 	struct device_list *dl_vgid, *dl_lvid;
 	int r = 0;
 
-	if (dev->vgid)
+	if (dev->flags & DEV_USED_FOR_LV)
 		/* already indexed */
 		return 1;
 


