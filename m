From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  3 Jan 2017 13:56:08 +0000 (UTC)
Subject: master - vgchange: max_pv limited to uint32
Message-ID: <20170103135608.D13016100A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4fd41cf67f0b9ea44a103b059dbbb2d74d8289eb
Commit:        4fd41cf67f0b9ea44a103b059dbbb2d74d8289eb
Parent:        9f65a3f0c54fc349da279f9a9e8f1b214945489e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 3 13:04:51 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 3 14:55:16 2017 +0100

vgchange: max_pv limited to uint32

Solves: https://bugzilla.redhat.com/1280496

The only reasonable behaviour here is to error on
any number out of accepted range (i.e. now numbers
wrapping around with some hidden logic).

As this is plain bug there is no support for
backward compatibility since noone should
set numbers >UINT32_MAX and expect 0 or error
depending on how big number was used....

TODO: more fields might need to be converted.
---
 WHATS_NEW                    |    1 +
 test/shell/vgchange-usage.sh |    7 +++++++
 tools/args.h                 |    2 +-
 3 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e5bbfe0..9e16b27 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  vgchange -p accepts only uint32 numbers.
   Report thin LV date for merged LV when the merge is in progress.
   Detect if snapshot merge really started before polling for progress.
   Checking LV for merging origin requires also it has merged snapshot.
diff --git a/test/shell/vgchange-usage.sh b/test/shell/vgchange-usage.sh
index 9163741..08d8114 100644
--- a/test/shell/vgchange-usage.sh
+++ b/test/shell/vgchange-usage.sh
@@ -53,6 +53,13 @@ not vgchange -p 2 $vg 2>err
 grep "MaxPhysicalVolumes is less than the current number $pv_count of PVs for" err
 check vg_field $vg max_pv 128
 
+# try some numbers around MAX limit (uint32)
+vgchange -p 4294967295 $vg
+invalid vgchange -p 4294967296 $vg
+invalid vgchange -p 18446744073709551615 $vg
+invalid vgchange -p 18446744073709551616 $vg
+check vg_field $vg max_pv 4294967295
+
 # vgchange -l MaxLogicalVolumes
 check vg_field $vg max_lv 0
 invalid vgchange -l -128 $vg
diff --git a/tools/args.h b/tools/args.h
index a04d81d..d5f1186 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -198,7 +198,7 @@ arg(novolumegroup_ARG, 'n', "novolumegroup", NULL, 0, 0)
 arg(oldpath_ARG, 'n', "oldpath", NULL, 0, 0)
 arg(options_ARG, 'o', "options", string_arg, ARG_GROUPABLE, 0)
 arg(sort_ARG, 'O', "sort", string_arg, ARG_GROUPABLE, 0)
-arg(maxphysicalvolumes_ARG, 'p', "maxphysicalvolumes", int_arg, 0, 0)
+arg(maxphysicalvolumes_ARG, 'p', "maxphysicalvolumes", uint32_arg, 0, 0)
 arg(permission_ARG, 'p', "permission", permission_arg, 0, 0)
 arg(partial_ARG, 'P', "partial", NULL, 0, 0)
 arg(physicalvolume_ARG, 'P', "physicalvolume", NULL, 0, 0)


