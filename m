From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:57:37 +0000 (UTC)
Subject: master - commands: add --configreport arg for all relevant commands
Message-ID: <20160620095737.D0B2761032@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2593cab5c4f6cd05edab521b0ae997077790234b
Commit:        2593cab5c4f6cd05edab521b0ae997077790234b
Parent:        083e538030e8ee5f8a888d11ddc7f06cd793678c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 20 11:57:24 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:57:24 2016 +0200

commands: add --configreport arg for all relevant commands

---
 tools/commands.h |   69 ++++++++++++++++++++++++++++++-----------------------
 1 files changed, 39 insertions(+), 30 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 4bebcd4..c0b3f3b 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -144,6 +144,7 @@ xx(fullreport,
    "\t[--binary]\n"
    "\t[-a|--all]\n"
    "\t[--commandprofile ProfileName]\n"
+   "\t[--configreport ReportName]\n"
    "\t[-d|--debug]\n"
    "\t[--foreign]\n"
    "\t[-h|--help]\n"
@@ -169,11 +170,12 @@ xx(fullreport,
    "\t[--version]\n"
    "\t[VolumeGroupName [VolumeGroupName...]]\n",
 
-   aligned_ARG, all_ARG, binary_ARG, foreign_ARG, ignorelockingfailure_ARG,
-   ignoreskippedcluster_ARG, logonly_ARG, nameprefixes_ARG, noheadings_ARG,
-   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG,
-   reportformat_ARG, rows_ARG, select_ARG, separator_ARG, shared_ARG,
-   sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
+   aligned_ARG, all_ARG, binary_ARG, configreport_ARG, foreign_ARG,
+   ignorelockingfailure_ARG, ignoreskippedcluster_ARG, logonly_ARG,
+   nameprefixes_ARG, noheadings_ARG, nolocking_ARG, nosuffix_ARG,
+   options_ARG, partial_ARG, readonly_ARG, reportformat_ARG, rows_ARG,
+   select_ARG, separator_ARG, shared_ARG, sort_ARG, trustcache_ARG,
+   unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(lastlog,
    "Display last command's log report",
@@ -481,6 +483,7 @@ xx(lvdisplay,
    "\t[-a|--all]\n"
    "\t[--binary]\n"
    "\t[--commandprofile ProfileName]\n"
+   "\t[--configreport ReportName]\n"
    "\t[-d|--debug]\n"
    "\t[--foreign]\n"
    "\t[-h|--help]\n"
@@ -504,11 +507,12 @@ xx(lvdisplay,
    "\t[--version]\n"
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
 
-    aligned_ARG, all_ARG, binary_ARG, colon_ARG, columns_ARG, foreign_ARG,
-    history_ARG, ignorelockingfailure_ARG, ignoreskippedcluster_ARG,
-    logonly_ARG, maps_ARG, noheadings_ARG, nosuffix_ARG, options_ARG, sort_ARG,
-    partial_ARG, readonly_ARG, reportformat_ARG, segments_ARG, select_ARG,
-    separator_ARG, shared_ARG, unbuffered_ARG, units_ARG)
+    aligned_ARG, all_ARG, binary_ARG, colon_ARG, columns_ARG,
+    configreport_ARG< foreign_ARG, history_ARG, ignorelockingfailure_ARG,
+    ignoreskippedcluster_ARG, logonly_ARG, maps_ARG, noheadings_ARG,
+    nosuffix_ARG, options_ARG, sort_ARG, partial_ARG, readonly_ARG,
+    reportformat_ARG, segments_ARG, select_ARG, separator_ARG,
+    shared_ARG, unbuffered_ARG, units_ARG)
 
 xx(lvextend,
    "Add space to a logical volume",
@@ -916,6 +920,7 @@ xx(pvdisplay,
    "\t[-a|--all]\n"
    "\t[--binary]\n"
    "\t[--commandprofile ProfileName]\n"
+   "\t[--configreport ReportName]\n"
    "\t[-d|--debug]\n"
    "\t[--foreign]\n"
    "\t[-h|--help]\n"
@@ -936,11 +941,11 @@ xx(pvdisplay,
    "\t[--version]\n"
    "\t[PhysicalVolumePath [PhysicalVolumePath...]]\n",
 
-   aligned_ARG, all_ARG, binary_ARG, colon_ARG, columns_ARG, foreign_ARG,
-   ignorelockingfailure_ARG, ignoreskippedcluster_ARG, logonly_ARG, maps_ARG,
-   noheadings_ARG, nosuffix_ARG, options_ARG, readonly_ARG, reportformat_ARG,
-   select_ARG, separator_ARG, shared_ARG, short_ARG, sort_ARG, unbuffered_ARG,
-   units_ARG)
+   aligned_ARG, all_ARG, binary_ARG, colon_ARG, columns_ARG, configreport_ARG,
+   foreign_ARG, ignorelockingfailure_ARG, ignoreskippedcluster_ARG,
+   logonly_ARG, maps_ARG, noheadings_ARG, nosuffix_ARG, options_ARG,
+   readonly_ARG, reportformat_ARG, select_ARG, separator_ARG, shared_ARG,
+   short_ARG, sort_ARG, unbuffered_ARG, units_ARG)
 
 /* ALL_VGS_IS_DEFAULT is for polldaemon to find pvmoves in-progress using process_each_vg. */
 
@@ -1013,6 +1018,7 @@ xx(pvs,
    "\t[--aligned]\n"
    "\t[--binary]\n"
    "\t[--commandprofile ProfileName]\n"
+   "\t[--configreport ReportName]\n"
    "\t[-d|--debug]\n"
    "\t[--foreign]\n"
    "\t[-h|-?|--help]\n"
@@ -1039,12 +1045,12 @@ xx(pvs,
    "\t[--version]\n"
    "\t[PhysicalVolume [PhysicalVolume...]]\n",
 
-   aligned_ARG, all_ARG, binary_ARG, foreign_ARG, ignorelockingfailure_ARG,
-   ignoreskippedcluster_ARG, logonly_ARG, nameprefixes_ARG, noheadings_ARG,
-   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG,
-   reportformat_ARG, rows_ARG, segments_ARG, select_ARG, separator_ARG,
-   shared_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG,
-   unquoted_ARG)
+   aligned_ARG, all_ARG, binary_ARG, configreport_ARG, foreign_ARG,
+   ignorelockingfailure_ARG, ignoreskippedcluster_ARG, logonly_ARG,
+   nameprefixes_ARG, noheadings_ARG, nolocking_ARG, nosuffix_ARG,
+   options_ARG, partial_ARG, readonly_ARG, reportformat_ARG, rows_ARG,
+   segments_ARG, select_ARG, separator_ARG, shared_ARG, sort_ARG,
+   trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(pvscan,
    "List all physical volumes",
@@ -1266,6 +1272,7 @@ xx(vgdisplay,
    "\t[--aligned]\n"
    "\t[--binary]\n"
    "\t[--commandprofile ProfileName]\n"
+   "\t[--configreport ReportName]\n"
    "\t[-d|--debug]\n"
    "\t[--foreign]\n"
    "\t[-h|--help]\n"
@@ -1288,10 +1295,10 @@ xx(vgdisplay,
    "\t[VolumeGroupName [VolumeGroupName...]]\n",
 
    activevolumegroups_ARG, aligned_ARG, binary_ARG, colon_ARG, columns_ARG,
-   foreign_ARG, ignorelockingfailure_ARG, ignoreskippedcluster_ARG,
-   logonly_ARG, noheadings_ARG, nosuffix_ARG, options_ARG, partial_ARG,
-   readonly_ARG, reportformat_ARG, select_ARG, shared_ARG, short_ARG,
-   separator_ARG, sort_ARG, unbuffered_ARG, units_ARG)
+   configreport_ARG, foreign_ARG, ignorelockingfailure_ARG,
+   ignoreskippedcluster_ARG, logonly_ARG, noheadings_ARG, nosuffix_ARG,
+   options_ARG, partial_ARG, readonly_ARG, reportformat_ARG, select_ARG,
+   shared_ARG, short_ARG, separator_ARG, sort_ARG, unbuffered_ARG, units_ARG)
 
 xx(vgexport,
    "Unregister volume group(s) from the system",
@@ -1448,6 +1455,7 @@ xx(vgs,
    "\t[--binary]\n"
    "\t[-a|--all]\n"
    "\t[--commandprofile ProfileName]\n"
+   "\t[--configreport ReportName]\n"
    "\t[-d|--debug]\n"
    "\t[--foreign]\n"
    "\t[-h|--help]\n"
@@ -1473,11 +1481,12 @@ xx(vgs,
    "\t[--version]\n"
    "\t[VolumeGroupName [VolumeGroupName...]]\n",
 
-   aligned_ARG, all_ARG, binary_ARG, foreign_ARG, ignorelockingfailure_ARG,
-   ignoreskippedcluster_ARG, logonly_ARG, nameprefixes_ARG, noheadings_ARG,
-   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG,
-   reportformat_ARG, rows_ARG, select_ARG, separator_ARG, shared_ARG,
-   sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
+   aligned_ARG, all_ARG, binary_ARG, configreport_ARG, foreign_ARG,
+   ignorelockingfailure_ARG, ignoreskippedcluster_ARG, logonly_ARG,
+   nameprefixes_ARG, noheadings_ARG, nolocking_ARG, nosuffix_ARG,
+   options_ARG, partial_ARG, readonly_ARG, reportformat_ARG, rows_ARG,
+   select_ARG, separator_ARG, shared_ARG, sort_ARG, trustcache_ARG,
+   unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(vgscan,
    "Search for all volume groups",


