From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Jun 2018 16:02:52 -0400
Subject: master - build: better srcdir builddir support
Message-ID: <201806142002.w5EK2qtw003552@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5b515db71ba13d2a4f328be6a97bb309401c5c69
Commit:        5b515db71ba13d2a4f328be6a97bb309401c5c69
Parent:        52ab3c1584cd40572e82d6add7a7c71204fa9721
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 14 20:57:02 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 14 22:02:01 2018 +0200

build: better srcdir builddir support

With the move to top-level makefile - there are some issues
with subdir recursive makefile.
Make the building more tolerant for now until fully resolved.
---
 Makefile.in      |    3 ++-
 test/Makefile.in |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index ae05aea..d076088 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -193,7 +193,8 @@ endif
 
 endif
 
-include test/unit/Makefile
+# FIXME: Drop once top-level make is resolved
+-include test/unit/Makefile
 include $(top_srcdir)/device_mapper/Makefile
 include $(top_srcdir)/base/Makefile
 
diff --git a/test/Makefile.in b/test/Makefile.in
index 4c3c715..ca2e2e1 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -357,7 +357,7 @@ LIB = $(addprefix lib/, $(LIB_SHARED) $(LIB_LOCAL) $(LIB_NOT) $(LIB_LINK_NOT) $(
 	touch $@
 
 .lib-dir-stamp:
-	$(MKDIR_P) lib
+	$(MKDIR_P) lib unit
 	for i in $(CMDS); do $(LN_S) -f lvm-wrapper lib/$$i; done
 	for i in daemons/clvmd/clvmd daemons/dmeventd/dmeventd \
 		tools/dmsetup daemons/lvmetad/lvmetad \


