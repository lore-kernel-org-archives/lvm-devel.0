From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 21 Sep 2021 19:51:08 +0000 (GMT)
Subject: main - cov: check dev_get_size result
Message-ID: <20210921195108.6F4A83858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e6d35874827f14d392c4ba4f8608eb0444230c7b
Commit:        e6d35874827f14d392c4ba4f8608eb0444230c7b
Parent:        30e27d2f8b8fbe3031c0e2863a22c77b577019a0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 21 18:50:26 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 21 21:03:47 2021 +0200

cov: check dev_get_size result

Check we have obtained some device size out of dev_get_size().
---
 tools/pvscan.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index b19b74b3e..a0be17e8e 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1268,8 +1268,12 @@ static int _online_devs(struct cmd_context *cmd, int do_all, struct dm_list *pvs
 		}
 
 		devsize = dev->size;
-		if (!devsize)
-			dev_get_size(dev, &devsize);
+		if (!devsize &&
+		    !dev_get_size(dev, &devsize)) {
+			log_print("pvscan[%d] PV %s can get device size.", getpid(), dev_name(dev));
+			release_vg(vg);
+			continue;
+		}
 		do_full_check = 0;
 
 		/* If use_full_md_check is set then this has already been done by filter. */


