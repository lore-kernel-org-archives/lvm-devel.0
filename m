From: David Teigland <teigland@sourceware.org>
Date: Thu, 2 Mar 2017 10:31:22 -0500
Subject: master - man lvchange: mention special activation vals
Message-ID: <201703021531.v22FVLao031139@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b76852bf35ca89f0c72bf30f1f86884ec53bc4c3
Commit:        b76852bf35ca89f0c72bf30f1f86884ec53bc4c3
Parent:        26ca308ba91454ab34a5eefa8c24d8f70a7c4308
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 2 09:30:27 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 2 09:31:06 2017 -0600

man lvchange: mention special activation vals

used by lvmlockd and clvmd.
---
 tools/args.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 66de6d5..471a3c2 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -807,8 +807,8 @@ arg(activate_ARG, 'a', "activate", activation_VAL, 0, 0,
     "if the list is set but empty, no LVs match.\n"
     "Autoactivation should be used during system boot to make it possible\n"
     "to select which LVs should be automatically activated by the system.\n"
-    "See lvmlockd(8) for more information about activation options for shared VGs.\n"
-    "See clvmd(8) for more information about activation options for clustered VGs.\n"
+    "See lvmlockd(8) for more information about activation options \\fBey\\fP and \\fBsy\\fP for shared VGs.\n"
+    "See clvmd(8) for more information about activation options \\fBey\\fP, \\fBsy\\fP, \\fBly\\fP and \\fBln\\fP for clustered VGs.\n"
     "#lvcreate\n"
     "Controls the active state of the new LV.\n"
     "\\fBy\\fP makes the LV active, or available.\n"


