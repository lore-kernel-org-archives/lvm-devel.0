From: Takahiro Yasui <takahiro.yasui@hds.com>
Date: Fri, 25 Jun 2010 13:25:23 -0400
Subject: [RFC][PATCH] lvm2: adjust region size of mirrored log
Message-ID: <5C30BE7ED8B03E448B2E104602D4848A5922886497@USINDEVS02.corp.hds.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix bz608048

The same region size is used for both mirror volume and mirrored
log volume, but when physical extent size is bigger than region size,
the size of mirror leg for mirrored log is smaller than the region size
and lvcreate command fails.

This patch adjusts a region size of mirrored log to a smaller value of
region size or physical extent size.


Signed-off-by: Takahiro Yasui <takahiro.yasui@hds.com>
---
 lib/metadata/mirror.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: LVM2-2.02.68/lib/metadata/mirror.c
===================================================================
--- LVM2-2.02.68.orig/lib/metadata/mirror.c
+++ LVM2-2.02.68/lib/metadata/mirror.c
@@ -1816,7 +1816,9 @@ int add_mirror_images(struct cmd_context
 	 * create and initialize mirror log
 	 */
 	if (log_count &&
-	    !(log_lv = _set_up_mirror_log(cmd, ah, lv, log_count, region_size,
+	    !(log_lv = _set_up_mirror_log(cmd, ah, lv, log_count,
+					  (region_size > lv->vg->extent_size) ?
+					  lv->vg->extent_size : region_size,
 					  alloc, mirror_in_sync()))) {
 		stack;
 		goto out_remove_images;

-- 
Takahiro Yasui
Hitachi Data Systems


