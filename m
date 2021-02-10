From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Feb 2021 14:43:53 +0000 (GMT)
Subject: main - snapshot: create origin of virtual snap read only
Message-ID: <20210210144353.940423857C7B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3cc9efc0ed48f7053f2e92f251586ea7d3edc06a
Commit:        3cc9efc0ed48f7053f2e92f251586ea7d3edc06a
Parent:        96910de4c7acbc11dc9f4c43925765847a059871
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 9 22:31:31 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 10 15:39:03 2021 +0100

snapshot: create origin of virtual snap read only

When creating old fashioned way thick virtual snapshot,
use read-only 'zero' _vorigin device.
---
 lib/metadata/lv_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 833d7f8c5..32bdc7990 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -8747,7 +8747,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		/* Create zero origin volume for spare snapshot */
 		if (lp->virtual_extents &&
 		    !(origin_lv = _create_virtual_origin(cmd, vg, lv->name,
-							 lp->permission,
+							 (lp->permission & ~LVM_WRITE),
 							 lp->virtual_extents)))
 			goto revert_new_lv;
 


