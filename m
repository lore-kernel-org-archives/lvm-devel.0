From: David Teigland <teigland@sourceware.org>
Date: Wed, 3 May 2017 16:27:38 -0400
Subject: master - man vgimport: add description for --all
Message-ID: <201705032027.v43KRcbU032258@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=892f3b1002837abeed5c0a239de107678c6fb794
Commit:        892f3b1002837abeed5c0a239de107678c6fb794
Parent:        ab1de07c9747074a5d3fa0a3f49a54310854a5a0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 3 15:19:19 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 3 15:19:19 2017 -0500

man vgimport: add description for --all

---
 tools/args.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 23a56cd..704b4e7 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -850,6 +850,8 @@ arg(all_ARG, 'a', "all", 0, 0, 0,
     "Removes all empty PVs if none are named on the command line.\n"
     "#pvchange\n"
     "Change all visible PVs.\n"
+    "#vgimport\n"
+    "Import all visible VGs.\n"
     "#lvscan\n"
     "#lvdisplay\n"
     "#lvs\n"


