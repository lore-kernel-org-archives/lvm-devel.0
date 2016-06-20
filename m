From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:40:37 +0000 (UTC)
Subject: master - commands: recognize --reportformat option for pvs, vgs, lvs and devtypes command
Message-ID: <20160620094037.E29C76031C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f8a93763e59eea8cef3762908c3e663c7a22a4fa
Commit:        f8a93763e59eea8cef3762908c3e663c7a22a4fa
Parent:        10a1b9e18248f08f11af2bb0214fa857d0c9d6fc
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon May 2 14:39:32 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:41 2016 +0200

commands: recognize --reportformat option for pvs,vgs,lvs and devtypes command

Enables --reportformat options for pvs, vgs, lvs, devtypes command.
---
 tools/commands.h |   31 +++++++++++++++++--------------
 1 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 888f3a2..b544ae1 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -73,6 +73,7 @@ xx(devtypes,
    "\t[--nosuffix]\n"
    "\t[-o|--options [+|-|#]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[--rows]\n"
    "\t[-S|--select Selection]\n"
    "\t[--separator Separator]\n"
@@ -80,10 +81,9 @@ xx(devtypes,
    "\t[--unquoted]\n"
    "\t[--version]\n",
 
-   aligned_ARG, binary_ARG, nameprefixes_ARG,
-   noheadings_ARG, nosuffix_ARG, options_ARG,
-   rows_ARG, select_ARG, separator_ARG, sort_ARG,
-   unbuffered_ARG, unquoted_ARG)
+   aligned_ARG, binary_ARG, nameprefixes_ARG, noheadings_ARG,
+   nosuffix_ARG, options_ARG, reportformat_ARG, rows_ARG,
+   select_ARG, separator_ARG, sort_ARG, unbuffered_ARG, unquoted_ARG)
 
 xx(dumpconfig,
    "Display and manipulate configuration information",
@@ -679,6 +679,7 @@ xx(lvs,
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial]\n"
    "\t[--readonly]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[--rows]\n"
    "\t[--segments]\n"
    "\t[-S|--select Selection]\n"
@@ -694,9 +695,9 @@ xx(lvs,
    aligned_ARG, all_ARG, binary_ARG, foreign_ARG, history_ARG,
    ignorelockingfailure_ARG, ignoreskippedcluster_ARG, nameprefixes_ARG,
    noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
-   readonly_ARG, rows_ARG, segments_ARG, select_ARG, separator_ARG,
-   shared_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG,
-   unquoted_ARG)
+   readonly_ARG, reportformat_ARG, rows_ARG, segments_ARG, select_ARG,
+   separator_ARG, shared_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG,
+   units_ARG, unquoted_ARG)
 
 xx(lvscan,
    "List all logical volumes in all volume groups",
@@ -955,6 +956,7 @@ xx(pvs,
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial]\n"
    "\t[--readonly]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[--rows]\n"
    "\t[--segments]\n"
    "\t[-S|--select Selection]\n"
@@ -969,9 +971,9 @@ xx(pvs,
 
    aligned_ARG, all_ARG, binary_ARG, foreign_ARG, ignorelockingfailure_ARG,
    ignoreskippedcluster_ARG, nameprefixes_ARG, noheadings_ARG, nolocking_ARG,
-   nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG, rows_ARG,
-   segments_ARG, select_ARG, separator_ARG, shared_ARG, sort_ARG, trustcache_ARG,
-   unbuffered_ARG, units_ARG, unquoted_ARG)
+   nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG, reportformat_ARG,
+   rows_ARG, segments_ARG, select_ARG, separator_ARG, shared_ARG, sort_ARG,
+   trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(pvscan,
    "List all physical volumes",
@@ -1367,6 +1369,7 @@ xx(vgs,
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial]\n"
    "\t[--readonly]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[--rows]\n"
    "\t[-S|--select Selection]\n"
    "\t[--separator Separator]\n"
@@ -1379,10 +1382,10 @@ xx(vgs,
    "\t[VolumeGroupName [VolumeGroupName...]]\n",
 
    aligned_ARG, all_ARG, binary_ARG, foreign_ARG, ignorelockingfailure_ARG,
-   ignoreskippedcluster_ARG, nameprefixes_ARG, noheadings_ARG,
-   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
-   readonly_ARG, rows_ARG, select_ARG, separator_ARG, shared_ARG, sort_ARG,
-   trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
+   ignoreskippedcluster_ARG, nameprefixes_ARG, noheadings_ARG, nolocking_ARG,
+   nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG, reportformat_ARG,
+   rows_ARG, select_ARG, separator_ARG, shared_ARG, sort_ARG, trustcache_ARG,
+   unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(vgscan,
    "Search for all volume groups",


