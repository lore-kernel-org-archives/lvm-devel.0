From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 8 Jun 2018 08:38:43 -0400
Subject: master - pvresize: add missing return
Message-ID: <201806081238.w58CchIw006029@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fb171edd4520a91012eb6ce6652c241609f5f761
Commit:        fb171edd4520a91012eb6ce6652c241609f5f761
Parent:        0c62ae3f8920ebb53397b2a904aa2e3dd3e73bed
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 5 21:21:26 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 8 14:36:56 2018 +0200

pvresize: add missing return

Log error path missed return 0.
Also fix some unneded bactraces (since log_error already shows
position).
---
 WHATS_NEW               |    1 +
 lib/metadata/pv_manip.c |    5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a727a40..a17902d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 3.0.0
 =============
+  Fix check if resized PV can also fit metadata area.
   Avoid showing internal error in lvs output or pvmoved LVs.
   Remove clvmd
   Remove lvmlib (api)
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index eaaa5e6..5fd80a2 100644
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


