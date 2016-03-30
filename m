From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 30 Mar 2016 12:36:05 +0000 (UTC)
Subject: master - dev-cache: cleanup: remove older part of the code in _index_dev_by_vgid_and_lvid
Message-ID: <20160330123605.5CA9360A4D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=26b8676b21e79fa2c8ed8fa2015a2a93e95b96f7
Commit:        26b8676b21e79fa2c8ed8fa2015a2a93e95b96f7
Parent:        06ef7ba8765d64044b008a33f1c1faeac6112a4a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Mar 30 14:35:06 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 30 14:35:12 2016 +0200

dev-cache: cleanup: remove older part of the code in _index_dev_by_vgid_and_lvid

Part of devel code, not applicable anymore...
---
 lib/device/dev-cache.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 50ef2f2..59921bc 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -529,10 +529,6 @@ static int _index_dev_by_vgid_and_lvid(struct device *dev)
 	struct device_list *dl_vgid, *dl_lvid;
 	int r = 0;
 
-	if (dev->vgid)
-		/* already indexed */
-		return 1;
-
 	/* Get holders for device. */
 	if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d/holders/", dm_sysfs_dir(), (int) MAJOR(dev->dev), (int) MINOR(dev->dev)) < 0) {
 		log_error("%s: dm_snprintf failed for path to holders directory.", devname);


