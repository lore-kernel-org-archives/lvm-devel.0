From: David Teigland <teigland@sourceware.org>
Date: Fri, 3 Mar 2017 17:12:20 -0500
Subject: master - man: move the full UNIT description
Message-ID: <201703032212.v23MCK8J026706@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=11589891d7793e6ba1fc520ef9496bd35b497912
Commit:        11589891d7793e6ba1fc520ef9496bd35b497912
Parent:        b6c4b7cfb07504229cb7ff1f02f4cce4ebdead6d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 3 16:10:40 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Mar 3 16:12:02 2017 -0600

man: move the full UNIT description

Part of the UNIT description was still living in the
--size description.  Move it to the Size[UNIT] description
since it is used by other options, not just --size.
---
 tools/args.h    |   12 ------------
 tools/command.c |    3 +++
 2 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 448f6aa..7c44256 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -1062,12 +1062,6 @@ arg(size_ARG, 'L', "size", ssizemb_VAL, 0, 0,
     "The --size and --extents options are alternate methods of specifying size.\n"
     "The total number of physical extents used will be\n"
     "greater when redundant data is needed for RAID levels.\n"
-    "A suffix can be chosen from: \\fBbBsSkKmMgGtTpPeE\\fP.\n"
-    "All units are base two values, regardless of letter capitalization:\n"
-    "b|B is bytes, s|S is sectors of 512 bytes,\n"
-    "k|K is kilobytes, m|M is megabytes,\n"
-    "g|G is gigabytes, t|T is terabytes,\n"
-    "p|P is petabytes, e|E is exabytes.\n"
     "#lvreduce\n"
     "#lvextend\n"
     "#lvresize\n"
@@ -1075,12 +1069,6 @@ arg(size_ARG, 'L', "size", ssizemb_VAL, 0, 0,
     "The --size and --extents options are alternate methods of specifying size.\n"
     "The total number of physical extents used will be\n"
     "greater when redundant data is needed for RAID levels.\n"
-    "A suffix can be chosen from: \\fBbBsSkKmMgGtTpPeE\\fP.\n"
-    "All units are base two values, regardless of letter capitalization:\n"
-    "b|B is bytes, s|S is sectors of 512 bytes,\n"
-    "k|K is kilobytes, m|M is megabytes,\n"
-    "g|G is gigabytes, t|T is terabytes,\n"
-    "p|P is petabytes, e|E is exabytes.\n"
     "The plus prefix \\fB+\\fP can be used, in which case\n"
     "the value is added to the current size,\n"
     "or the minus prefix \\fB-\\fP can be used, in which case\n"
diff --git a/tools/command.c b/tools/command.c
index 70f9bee..5fc5ff3 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -3093,6 +3093,9 @@ void print_man_all_positions_desc(struct command_name *cname)
 	       "capitalization, e.g. 'k' and 'K' both refer to 1024.\n"
 	       "The default input unit is specified by letter, followed by |UNIT.\n"
 	       "UNIT represents other possible input units: \\fBbBsSkKmMgGtTpPeE\\fP.\n"
+	       "b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,\n"
+	       "m|M is megabytes, g|G is gigabytes, t|T is terabytes,\n"
+	       "p|P is petabytes, e|E is exabytes.\n"
 	       "(This should not be confused with the output control --units, where\n"
 	       "capital letters mean multiple of 1000.)\n");
 


