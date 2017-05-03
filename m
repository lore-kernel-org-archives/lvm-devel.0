From: David Teigland <teigland@sourceware.org>
Date: Wed, 3 May 2017 16:27:29 -0400
Subject: master - man pvchange: add description for --all
Message-ID: <201705032027.v43KRT7D032229@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=27736676275fefa3367db2939ddfa0c8cce48c04
Commit:        27736676275fefa3367db2939ddfa0c8cce48c04
Parent:        f7edadf87087ab4357837f09bc9356dff24306f0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 3 15:03:14 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 3 15:03:14 2017 -0500

man pvchange: add description for --all

---
 tools/args.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 87b33e7..23a56cd 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -848,6 +848,8 @@ arg(activate_ARG, 'a', "activate", activation_VAL, 0, 0,
 arg(all_ARG, 'a', "all", 0, 0, 0,
     "#vgreduce\n"
     "Removes all empty PVs if none are named on the command line.\n"
+    "#pvchange\n"
+    "Change all visible PVs.\n"
     "#lvscan\n"
     "#lvdisplay\n"
     "#lvs\n"


