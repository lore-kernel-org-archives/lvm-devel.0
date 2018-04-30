From: Joe Thornber <thornber@sourceware.org>
Date: Mon, 30 Apr 2018 11:34:38 -0400
Subject: master - build: fix typo in dmeventd/plugins/Makefile.in
Message-ID: <201804301534.w3UFYci6019951@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1ddbbb67e0928ffcad45be61bd32278e9ddb4f7d
Commit:        1ddbbb67e0928ffcad45be61bd32278e9ddb4f7d
Parent:        9384b2b5c59e9bca8c2054f76b62155a64c51c38
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Apr 30 15:31:57 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon Apr 30 15:31:57 2018 +0100

build: fix typo in dmeventd/plugins/Makefile.in

---
 daemons/dmeventd/plugins/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/plugins/Makefile.in b/daemons/dmeventd/plugins/Makefile.in
index aea44cd..27edf55 100644
--- a/daemons/dmeventd/plugins/Makefile.in
+++ b/daemons/dmeventd/plugins/Makefile.in
@@ -16,7 +16,7 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-SUBDIRS += lvm2 snapshot raid thin mirrors
+SUBDIRS += lvm2 snapshot raid thin mirror
 
 ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS = lvm2 mirror snapshot raid thin


