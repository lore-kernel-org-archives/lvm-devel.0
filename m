From: David Teigland <teigland@sourceware.org>
Date: Mon, 3 Apr 2017 15:16:20 -0400
Subject: master - man: fix description of --partial option
Message-ID: <201704031916.v33JGKeE015855@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=51ff707ac859b6ab1ba1bc6cc8d9ea154632f2f7
Commit:        51ff707ac859b6ab1ba1bc6cc8d9ea154632f2f7
Parent:        e0f284d3728d3381966dd290e205951ed99e54f9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 3 14:15:29 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 3 14:15:29 2017 -0500

man: fix description of --partial option

---
 tools/args.h |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 8d6b44d..24e3918 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -1223,13 +1223,11 @@ arg(maxphysicalvolumes_ARG, 'p', "maxphysicalvolumes", uint32_VAL, 0, 0,
 arg(permission_ARG, 'p', "permission", permission_VAL, 0, 0,
     "Set access permission to read only \\fBr\\fP or read and write \\fBrw\\fP.\n")
 
-/* FIXME: I left out some of the previous description that didn't sound correct. */
-
 arg(partial_ARG, 'P', "partial", 0, 0, 0,
-    "When set, the tools will do their best to provide access to VGs\n"
-    "that are only partially available (one or more PVs belonging\n"
-    "to the VG are missing from the system). Metadata may not be\n"
-    "changed with this option.\n")
+    "Commands will do their best to activate LVs with missing PV extents.\n"
+    "Missing extents may be replaced with error or zero segments\n"
+    "according to the lvm.conf missing_stripe_filler setting.\n"
+    "Metadata may not be changed with this option.\n")
 
 /* Not used */
 arg(physicalvolume_ARG, 'P', "physicalvolume", 0, 0, 0, NULL)


