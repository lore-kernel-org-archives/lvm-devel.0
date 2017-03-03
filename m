From: David Teigland <teigland@sourceware.org>
Date: Fri, 3 Mar 2017 12:16:16 -0500
Subject: master - args: update select description
Message-ID: <201703031716.v23HGGJn022042@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=191a2517beb85fcb041ecb92fad3b45a8d008b0e
Commit:        191a2517beb85fcb041ecb92fad3b45a8d008b0e
Parent:        1a0d57f89503e9f25860ca85acb7d2a3e80cad9c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 3 09:53:11 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Mar 3 09:53:11 2017 -0600

args: update select description

mention --select help and --options help.
---
 tools/args.h |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index eb11f38..53ff870 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -1297,9 +1297,10 @@ arg(stdin_ARG, 's', "stdin", 0, 0, 0, NULL)
 
 arg(select_ARG, 'S', "select", string_VAL, ARG_GROUPABLE, 0,
     "Select objects for processing and reporting based on specified criteria.\n"
-    "The criteria syntax is described in lvmreport(7) under Selection.\n"
-    "For reporting commands, display rows that match the criteria.\n"
-    "All rows can be displayed with an additional \"selected\" field (-o selected)\n"
+    "The criteria syntax is described by \\fB--select help\\fP and \\fBlvmreport\\fP(7).\n"
+    "For reporting commands, one row is displayed for each object matching the criteria.\n"
+    "See \\fB--options help\\fP for selectable object fields.\n"
+    "Rows can be displayed with an additional \"selected\" field (-o selected)\n"
     "showing 1 if the row matches the selection and 0 otherwise.\n"
     "For non-reporting commands which process LVM entities, the selection is\n"
     "used to choose items to process.\n")


