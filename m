From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:19:59 +0000 (UTC)
Subject: master - commands: lvs: recognize -H|--history switch
Message-ID: <20160303131959.4028D6024B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e112f5ce05792885ffa5082d7073b139fe468149
Commit:        e112f5ce05792885ffa5082d7073b139fe468149
Parent:        28f96d5ab617cc41b8aab66c7cb19d750d68d2fd
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:23:34 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:49:14 2016 +0100

commands: lvs: recognize -H|--history switch

When lvs command is used together with the -H|--history switch,
all historical LVs are reported as well.
---
 tools/commands.h |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 25784bf..ffc15b5 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -663,6 +663,7 @@ xx(lvs,
    "\t[-d|--debug]\n"
    "\t[--foreign]\n"
    "\t[-h|--help]\n"
+   "\t[-H|--history]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoreskippedcluster]\n"
    "\t[--nameprefixes]\n"
@@ -684,11 +685,12 @@ xx(lvs,
    "\t[--version]\n"
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
 
-   aligned_ARG, all_ARG, binary_ARG, foreign_ARG, ignorelockingfailure_ARG,
-   ignoreskippedcluster_ARG, nameprefixes_ARG, noheadings_ARG,
-   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
-   readonly_ARG, rows_ARG, segments_ARG, select_ARG, separator_ARG, shared_ARG,
-   sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
+   aligned_ARG, all_ARG, binary_ARG, foreign_ARG, history_ARG,
+   ignorelockingfailure_ARG, ignoreskippedcluster_ARG, nameprefixes_ARG,
+   noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
+   readonly_ARG, rows_ARG, segments_ARG, select_ARG, separator_ARG,
+   shared_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG,
+   unquoted_ARG)
 
 xx(lvscan,
    "List all logical volumes in all volume groups",


