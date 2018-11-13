From: David Teigland <teigland@sourceware.org>
Date: Tue, 13 Nov 2018 18:28:41 -0500
Subject: master - man: remove cluster references
Message-ID: <201811132328.wADNSf1R006676@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=970f49dcab64bdef45bce2122ead51dd17e3c48b
Commit:        970f49dcab64bdef45bce2122ead51dd17e3c48b
Parent:        517332e78ddf0ea1ed5735925b1047cf5cf4f8f8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 13 16:15:41 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 13 16:15:41 2018 -0600

man: remove cluster references

---
 tools/args.h |   14 ++++----------
 1 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index cc65be5..3e737f8 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -498,12 +498,9 @@ arg(readonly_ARG, '\0', "readonly", 0, 0, 0,
     "Run the command in a special read-only mode which will read on-disk\n"
     "metadata without needing to take any locks. This can be used to peek\n"
     "inside metadata used by a virtual machine image while the virtual\n"
-    "machine is running.\n"
-    "It can also be used to peek inside the metadata of clustered VGs\n"
-    "when clustered locking is not configured or running. No attempt\n"
-    "will be made to communicate with the device-mapper kernel driver, so\n"
-    "this option is unable to report whether or not LVs are\n"
-    "actually in use.\n")
+    "machine is running. No attempt will be made to communicate with the\n"
+    "device-mapper kernel driver, so this option is unable to report whether\n"
+    "or not LVs are actually in use.\n")
 
 arg(refresh_ARG, '\0', "refresh", 0, 0, 0,
     "If the LV is active, reload its metadata.\n"
@@ -592,7 +589,6 @@ arg(shared_ARG, '\0', "shared", 0, 0, 0,
     "lvmlockd will select lock type sanlock or dlm depending on which lock\n"
     "manager is running. This allows multiple hosts to share a VG on shared\n"
     "devices. lvmlockd and a lock manager must be configured and running.\n"
-    "(A shared VG using lvmlockd is different from a clustered VG using clvmd.)\n"
     "See \\fBlvmlockd\\fP(8) for more information about shared VGs.\n"
     "#vgs\n"
     "#lvs\n"
@@ -894,7 +890,6 @@ arg(activate_ARG, 'a', "activate", activation_VAL, 0, 0,
     "Autoactivation should be used during system boot to make it possible\n"
     "to select which LVs should be automatically activated by the system.\n"
     "See \\fBlvmlockd\\fP(8) for more information about activation options \\fBey\\fP and \\fBsy\\fP for shared VGs.\n"
-    "See \\fBclvmd\\fP(8) for more information about activation options \\fBey\\fP, \\fBsy\\fP, \\fBly\\fP and \\fBln\\fP for clustered VGs.\n"
     "#lvcreate\n"
     "Controls the active state of the new LV.\n"
     "\\fBy\\fP makes the LV active, or available.\n"
@@ -907,8 +902,7 @@ arg(activate_ARG, 'a', "activate", activation_VAL, 0, 0,
     "If autoactivation \\fBay\\fP is used, the LV is only activated\n"
     "if it matches an item in lvm.conf activation/auto_activation_volume_list.\n"
     "\\fBay\\fP implies --zero n and --wipesignatures n.\n"
-    "See \\fBlvmlockd\\fP(8) for more information about activation options for shared VGs.\n"
-    "See \\fBclvmd\\fP(8) for more information about activation options for clustered VGs.\n")
+    "See \\fBlvmlockd\\fP(8) for more information about activation options for shared VGs.\n")
 
 arg(all_ARG, 'a', "all", 0, 0, 0,
     "#vgreduce\n"


