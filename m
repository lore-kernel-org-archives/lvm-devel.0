From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 5 Jul 2019 19:26:18 -0400
Subject: stable-2.02 - cov: release iterator on error path
Message-ID: <201907052326.x65NQIMD009715@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=23478d9d2161d1233d0dde1ca40c81d47292bd87
Commit:        23478d9d2161d1233d0dde1ca40c81d47292bd87
Parent:        b0e1019add988b91fb41355566a34a3b2e182569
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 28 13:26:11 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jul 6 01:24:28 2019 +0200

cov: release iterator on error path

Another missed release on error path.
---
 lib/label/label.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index a535bd4..bc31a7c 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -912,7 +912,7 @@ int label_scan(struct cmd_context *cmd)
 
 	if (!scan_bcache) {
 		if (!_setup_bcache(dm_list_size(&all_devs)))
-			return 0;
+			return_0;
 	}
 
 	_scan_list(cmd, cmd->full_filter, &all_devs, NULL);
@@ -987,8 +987,11 @@ int label_scan_pvscan_all(struct cmd_context *cmd, struct dm_list *scan_devs)
 	}
 
 	while ((dev = dev_iter_get(iter))) {
-		if (!(devl = dm_zalloc(sizeof(*devl))))
+		if (!(devl = dm_zalloc(sizeof(*devl)))) {
+			log_error("Failed to allocated device list.");
+			dev_iter_destroy(iter);
 			return 0;
+		}
 		devl->dev = dev;
 		dm_list_add(&all_devs, &devl->list);
 
@@ -1013,7 +1016,7 @@ int label_scan_pvscan_all(struct cmd_context *cmd, struct dm_list *scan_devs)
 
 	if (!scan_bcache) {
 		if (!_setup_bcache(dm_list_size(&all_devs)))
-			return 0;
+			return_0;
 	}
 
 	_scan_list(cmd, cmd->lvmetad_filter, &all_devs, NULL);


