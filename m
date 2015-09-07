From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  7 Sep 2015 15:45:26 +0000 (UTC)
Subject: master - makefiles: do not generate tags for everyone
Message-ID: <20150907154526.17B4A60F51@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=acfc56957c008d30c98ced5fae5f7888ec2a5a22
Commit:        acfc56957c008d30c98ced5fae5f7888ec2a5a22
Parent:        3ba431e79e4914dfaf3cc74aeb52b46757acc8df
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 7 13:44:14 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 7 17:44:04 2015 +0200

makefiles: do not generate tags for everyone

Create tags file only on request (make tags).
Also clean file with 'make clean'.
---
 Makefile.in |    5 ++---
 WHATS_NEW   |    1 +
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 1ce9ca8..d9ac815 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -229,10 +229,9 @@ endif
 
 ifneq ($(shell which ctags),)
 .PHONY: tags
-all: tags
 tags:
-	test -z "$(shell find $(top_srcdir) -type f -name '*.[ch]' -newer tags | head -1)" || $(RM) tags
+	test -z "$(shell find $(top_srcdir) -type f -name '*.[ch]' -newer tags 2>/dev/null | head -1)" || $(RM) tags
 	test -f tags || find $(top_srcdir) -maxdepth 4 -type f -name '*.[ch]' -exec ctags -a '{}' +
 
-DISTCLEAN_TARGETS += tags
+CLEAN_TARGETS += tags
 endif
diff --git a/WHATS_NEW b/WHATS_NEW
index 1ce1c81..c9dec02 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.131 - 
 =====================================
+  Make tags only when requested via 'make tags'.
   Configure supports --disable-dependency-tracking for one-time builds.
   Fix usage of configure.h when building in srcdir != builddir.
 


