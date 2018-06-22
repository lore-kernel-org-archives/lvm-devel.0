From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 22 Jun 2018 09:08:03 -0400
Subject: 2018-06-01-stable - pvresize: add missing return
Message-ID: <201806221308.w5MD83Ou019668@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5503699c3701ed4875c274f12b8fdd6b099db71b
Commit:        5503699c3701ed4875c274f12b8fdd6b099db71b
Parent:        e0bfc946cb182a021bb7a74a11ec7ac51ad9a7b0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 5 21:21:26 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 22 12:37:09 2018 +0200

pvresize: add missing return

Log error path missed return 0.
Also fix some unneded bactraces (since log_error already shows
position).
---
 WHATS_NEW               |    1 +
 lib/metadata/pv_manip.c |    5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b12ca25..fff7222 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.180 - 
 =================================
+  Fix check if resized PV can also fit metadata area.
   Reopen devices RDWR before writing to avoid udev issues.
   Fix mem leak in clvmd.
 
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index e75be76..48f6ad0 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -566,6 +566,7 @@ static int _pv_resize(struct physical_volume *pv, struct volume_group *vg, uint6
 		log_error("Size must exceed physical extent start "
 			  "of %" PRIu64 " sectors on PV %s.",
 			  pv_pe_start(pv), pv_dev_name(pv));
+		return 0;
 	}
 
 	old_pe_count = pv->pe_count;
@@ -645,7 +646,7 @@ int pv_resize_single(struct cmd_context *cmd,
 						  pv_name, display_size(cmd, new_size),
 						  display_size(cmd, size)) == 'n') {
 				log_error("Physical Volume %s not resized.", pv_name);
-				goto_out;
+				goto out;
 			}
 
 		}  else if (new_size < size)
@@ -653,7 +654,7 @@ int pv_resize_single(struct cmd_context *cmd,
 						  pv_name, display_size(cmd, new_size),
 						  display_size(cmd, size)) == 'n') {
 				log_error("Physical Volume %s not resized.", pv_name);
-				goto_out;
+				goto out;
 			}
 
 		if (new_size == size)


