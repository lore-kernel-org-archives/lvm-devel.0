From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 29 Jun 2012 20:24:19 +0000 (UTC)
Subject: master - toollib: fix ignored_mdas process_each_pv rescan
Message-ID: <20120629202420.030B71707@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1d0a2b919fe173e3a25e5f19d535588bb5b214e2
Commit:        1d0a2b919fe173e3a25e5f19d535588bb5b214e2
Parent:        d84e1ae5f2de569db06293aac371ce7dde1cfd62
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jun 29 21:22:09 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jun 29 21:22:09 2012 +0100

toollib: fix ignored_mdas process_each_pv rescan

In process_each_pv() if we haven't yet scanned and the PV appears
to be an orphan, we must scan the other PVs looking for mdas that
reference it to find out what VG it is in.

1. If the PV has no mdas, we must scan.
2. If the PV has an mda that is not ignored we do not need to scan.
3. If the PV has an mda that is ignored, we do need to scan.

This patch fixes case 3.

> pvs -o +mda_count,vg_mda_count /dev/loop[0123]
  PV         VG   Fmt  Attr PSize  PFree  #PMda #VMda
  /dev/loop0 vg3  lvm2 a-   96.00m 96.00m     0     1
  /dev/loop1 vg3  lvm2 a-   96.00m 96.00m     1     1
  /dev/loop2 vg2  lvm2 a-   96.00m 96.00m     1     2
  /dev/loop3 vg2  lvm2 a-   28.00m 28.00m     1     2

Before:
> pvs /dev/loop2 /dev/loop3 /dev/loop0 /dev/loop1 --unbuffered
  PV         VG   Fmt  Attr PSize   PFree
  /dev/loop2      lvm2 a--  100.00m 100.00m
  /dev/loop3 vg2  lvm2 a--   28.00m  28.00m
  /dev/loop0      lvm2 a--  100.00m 100.00m
  /dev/loop1 vg3  lvm2 a--   96.00m  96.00m

After:
> pvs /dev/loop2 /dev/loop3 /dev/loop0 /dev/loop1 --unbuffered
  PV         VG   Fmt  Attr PSize  PFree
  /dev/loop2 vg2  lvm2 a--  96.00m 96.00m
  /dev/loop3 vg2  lvm2 a--  28.00m 28.00m
  /dev/loop0 vg3  lvm2 a--  96.00m 96.00m
  /dev/loop1 vg3  lvm2 a--  96.00m 96.00m
---
 WHATS_NEW       |    1 +
 tools/toollib.c |    3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d19df2d..2e649b1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Fix test for PV with unknown VG in process_each_pv to ignore ignored mdas.
   Update man pages with --activate ay option and auto_activation_volume_list.
   Fix _alloc_parallel_area to avoid picking already-full areas for raid devices.
   Use vgchange -aay instead of vgchange -ay in clmvd init script.
diff --git a/tools/toollib.c b/tools/toollib.c
index 142de55..0f6810b 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -770,8 +770,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 				 * PV on the system.
 				 */
 				if (!scanned && is_orphan(pv) &&
-				    !dm_list_size(&pv->fid->metadata_areas_in_use) &&
-				    !dm_list_size(&pv->fid->metadata_areas_ignored)) {
+				    !dm_list_size(&pv->fid->metadata_areas_in_use)) {
 					if (!scan_label_only &&
 					    !scan_vgs_for_pvs(cmd, 1)) {
 						stack;


