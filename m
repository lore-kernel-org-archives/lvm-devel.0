From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 12:01:26 +0000 (GMT)
Subject: stable-2.02 - snapshot: create origin of virtual snap read only
Message-ID: <20210217120126.838DC3896839@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dee104668ea5b39518a3a220d360d4624c3f3575
Commit:        dee104668ea5b39518a3a220d360d4624c3f3575
Parent:        02978e1f0135b75789669ee4042855b08f57f8b4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 9 22:31:31 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 12:14:54 2021 +0100

snapshot: create origin of virtual snap read only

When creating old fashioned way thick virtual snapshot,
use read-only 'zero' _vorigin device.
---
 lib/metadata/lv_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8dd3e7140..11fab6d7b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -8273,7 +8273,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		/* Create zero origin volume for spare snapshot */
 		if (lp->virtual_extents &&
 		    !(origin_lv = _create_virtual_origin(cmd, vg, lv->name,
-							 lp->permission,
+							 (lp->permission & ~LVM_WRITE),
 							 lp->virtual_extents)))
 			goto revert_new_lv;
 


