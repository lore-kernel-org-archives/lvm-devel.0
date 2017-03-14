From: David Teigland <teigland@sourceware.org>
Date: Tue, 14 Mar 2017 14:52:45 -0400
Subject: master - args: clarify repeated --options lists
Message-ID: <201703141852.v2EIqjWf029095@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5942fd18dbf961fa1222a76b7f95ddef6c3edf09
Commit:        5942fd18dbf961fa1222a76b7f95ddef6c3edf09
Parent:        88b05391ffbb168b6c35edc2f6b8428d8b22e815
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 14 13:52:09 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 14 13:52:09 2017 -0500

args: clarify repeated --options lists

---
 tools/args.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index fd0ad0c..9d839b5 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -1197,7 +1197,8 @@ arg(options_ARG, 'o', "options", string_VAL, ARG_GROUPABLE, 0,
     "\\fB-\\fP will remove the specified fields from the default fields, and\n"
     "\\fB#\\fP will compact specified fields (removing them when empty for all rows.)\n"
     "Use \\fB-o help\\fP to view the list of all available fields.\n"
-    "The -o option can be repeated, providing several lists.\n"
+    "Use separate lists of fields to add, remove or compact by repeating the -o option:\n"
+    "-o+field1,field2 -o-field3,field4 -o#field5.\n"
     "These lists are evaluated from left to right.\n"
     "Use field name \\fBlv_all\\fP to view all LV fields,\n"
     "\\fBvg_all\\fP all VG fields,\n"


