From: James Johnston <johnstonj.public@codenest.com>
Date: Sat, 2 Apr 2016 04:20:13 -0000
Subject: [PATCH] RAID: fix incorrect exit status from lvchange --syncaction
Message-ID: <009201d18c96$f56c3ef0$e044bcd0$@codenest.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This patch fixes a bug where lvchange --syncaction returns a successful exit
status even when it actually failed.

Test case:

$ lvchange --syncaction repair VG/DataCache
$ lvchange --syncaction repair VG/DataCache
  VG/DataCache is currently "repair".  Unable to switch to "repair".
$ echo $?
0

Since it gave an error, I'd expect the exit status to be non-zero.

>From 2f12e1f2aa933dca100a9dc505c1a6adfb7b99fd Mon Sep 17 00:00:00 2001
From: James Johnston <johnstonj.public@codenest.com>
Date: Sat, 2 Apr 2016 04:04:59 +0000
Subject: [PATCH] RAID: fix incorrect exit status from lvchange --syncaction

Some of the possible errors from lvchange don't return a non-zero
exit status: for example, if a repair is already in progress.

This is because lv_raid_message erroneously sets the return value to
success prematurely, and it's not subsequently reset to a failing
value.

Signed-off-by: James Johnston <johnstonj.public@codenest.com>
---
 lib/activate/activate.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index a3b2379..1713b8c 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1013,7 +1013,7 @@ int lv_raid_message(const struct logical_volume *lv, const char *msg)
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
 
-	if (!(r = dev_manager_raid_status(dm, lv, &status))) {
+	if (!dev_manager_raid_status(dm, lv, &status)) {
 		log_error("Failed to retrieve status of %s.",
 			  display_lvname(lv));
 		goto out;
-- 
1.9.5.msysgit.1



