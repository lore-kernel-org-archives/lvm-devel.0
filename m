From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:40:48 +0000 (UTC)
Subject: master - args: add --configreport arg
Message-ID: <20160620094048.6B3036031C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=28b4c48e2ae66b87bbb5d8fd29b761edba63a90e
Commit:        28b4c48e2ae66b87bbb5d8fd29b761edba63a90e
Parent:        d23c5b93183675199ff78ff288e4bbd12f935515
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 16 15:49:18 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:42 2016 +0200

args: add --configreport arg

---
 WHATS_NEW        |    1 +
 tools/args.h     |    1 +
 tools/commands.h |    3 ++-
 3 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 626851e..8afc577 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Add --configreport option to select report for which next options are applied.
   Add support for priorities on grouping command arguments.
   Add report/{pvs,vgs,lvs,pvsegs,segs}_{cols,sort}_full to lvm.conf.
   Add lvm fullreport command for joined PV, VG, LV and segment report per VG.
diff --git a/tools/args.h b/tools/args.h
index 8d66809..c0e0864 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -31,6 +31,7 @@ arg(cachemode_ARG, '\0', "cachemode", cachemode_arg, 0, 0)
 arg(cachepool_ARG, '\0', "cachepool", string_arg, 0, 0)
 arg(commandprofile_ARG, '\0', "commandprofile", string_arg, 0, 0)
 arg(config_ARG, '\0', "config", string_arg, 0, 0)
+arg(configreport_ARG, '\0', "configreport", string_arg, ARG_GROUPABLE, 1)
 arg(configtype_ARG, '\0', "type", string_arg, 0, 0)
 arg(corelog_ARG, '\0', "corelog", NULL, 0, 0)
 arg(dataalignment_ARG, '\0', "dataalignment", size_kb_arg, 0, 0)
diff --git a/tools/commands.h b/tools/commands.h
index a9e4be5..3f0fff5 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -714,6 +714,7 @@ xx(lvs,
    "\t[--aligned]\n"
    "\t[--binary]\n"
    "\t[--commandprofile ProfileName]\n"
+   "\t[--configreport ReportName]\n"
    "\t[-d|--debug]\n"
    "\t[--foreign]\n"
    "\t[-h|--help]\n"
@@ -740,7 +741,7 @@ xx(lvs,
    "\t[--version]\n"
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
 
-   aligned_ARG, all_ARG, binary_ARG, foreign_ARG, history_ARG,
+   aligned_ARG, all_ARG, binary_ARG, configreport_ARG, foreign_ARG, history_ARG,
    ignorelockingfailure_ARG, ignoreskippedcluster_ARG, nameprefixes_ARG,
    noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
    readonly_ARG, reportformat_ARG, rows_ARG, segments_ARG, select_ARG,


