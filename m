From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 24 Jun 2016 09:10:38 +0000 (UTC)
Subject: master - commands: fix typo in arg assignment
Message-ID: <20160624091038.5F14360F52@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=14da3cc793a368f925f26706e6b50f91a6dbede1
Commit:        14da3cc793a368f925f26706e6b50f91a6dbede1
Parent:        e88e9ee9eda8981cccb03d053189d05718891d53
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jun 24 11:10:10 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 24 11:10:10 2016 +0200

commands: fix typo in arg assignment

---
 tools/commands.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index ed86b7f..5589c9e 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -508,7 +508,7 @@ xx(lvdisplay,
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
 
     aligned_ARG, all_ARG, binary_ARG, colon_ARG, columns_ARG,
-    configreport_ARG< foreign_ARG, history_ARG, ignorelockingfailure_ARG,
+    configreport_ARG, foreign_ARG, history_ARG, ignorelockingfailure_ARG,
     ignoreskippedcluster_ARG, logonly_ARG, maps_ARG, noheadings_ARG,
     nosuffix_ARG, options_ARG, sort_ARG, partial_ARG, readonly_ARG,
     reportformat_ARG, segments_ARG, select_ARG, separator_ARG,


