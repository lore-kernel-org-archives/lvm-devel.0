From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  6 Jan 2017 22:40:19 +0000 (UTC)
Subject: master - vgchange: also -l is uint32
Message-ID: <20170106224019.2707D60506@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0d2a9ebec6b7555a09f26aa513b2a2f94fc19027
Commit:        0d2a9ebec6b7555a09f26aa513b2a2f94fc19027
Parent:        8a93cde75ef4a4b260d937c5924267d0eab31df3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 6 21:24:16 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 6 21:51:36 2017 +0100

vgchange: also -l is uint32

---
 test/shell/vgchange-usage.sh |    5 +++++
 tools/args.h                 |    4 ++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/test/shell/vgchange-usage.sh b/test/shell/vgchange-usage.sh
index 08d8114..44e0fd9 100644
--- a/test/shell/vgchange-usage.sh
+++ b/test/shell/vgchange-usage.sh
@@ -63,6 +63,11 @@ check vg_field $vg max_pv 4294967295
 # vgchange -l MaxLogicalVolumes
 check vg_field $vg max_lv 0
 invalid vgchange -l -128 $vg
+vgchange -l 4294967295 $vg
+invalid vgchange -l 4294967296 $vg
+invalid vgchange -l 18446744073709551615 $vg
+invalid vgchange -l 18446744073709551616 $vg
+check vg_field $vg max_lv 4294967295
 vgchange -l 128 $vg
 check vg_field $vg max_lv 128
 
diff --git a/tools/args.h b/tools/args.h
index d5f1186..a6fc77c 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -178,8 +178,8 @@ arg(interval_ARG, 'i', "interval", int_arg, 0, 0)
 arg(iop_version_ARG, 'i', "iop_version", NULL, 0, 0)
 arg(stripes_ARG, 'i', "stripes", int_arg, 0, 0)
 arg(stripesize_ARG, 'I', "stripesize", size_kb_arg, 0, 0)
-arg(logicalvolume_ARG, 'l', "logicalvolume", int_arg, 0, 0)
-arg(maxlogicalvolumes_ARG, 'l', "maxlogicalvolumes", int_arg, 0, 0)
+arg(logicalvolume_ARG, 'l', "logicalvolume", uint32_arg, 0, 0)
+arg(maxlogicalvolumes_ARG, 'l', "maxlogicalvolumes", uint32_arg, 0, 0)
 arg(extents_ARG, 'l', "extents", int_arg_with_sign_and_percent, 0, 0)
 arg(list_ARG, 'l', "list", NULL, 0, 0)
 arg(lvmpartition_ARG, 'l', "lvmpartition", NULL, 0, 0)


