From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 11 May 2015 14:10:59 +0000 (UTC)
Subject: master - makefiles: move clean
Message-ID: <20150511141059.9B02060EF1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=20e9ec35836fc4dd8064f40068e5be83dbf67bfa
Commit:        20e9ec35836fc4dd8064f40068e5be83dbf67bfa
Parent:        62e7a6ca1a3479017b026c380a97c9f826b087da
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 11 16:08:58 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 11 16:08:58 2015 +0200

makefiles: move clean

Move clean: target below, so it's not a default target to execute.
---
 Makefile.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index ac806bb..a180d10 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -49,8 +49,6 @@ tools.distclean: test.distclean
 endif
 DISTCLEAN_DIRS += lcov_reports*
 DISTCLEAN_TARGETS += config.cache config.log config.status make.tmpl
-clean:
-	$(RM) -r build
 
 include make.tmpl
 
@@ -103,6 +101,8 @@ conf.generate: tools
 
 VER = LVM2. at LVM_MAJOR@. at LVM_MINOR@. at LVM_PATCHLEVEL@
 CLEAN_TARGETS += $(VER).tgz
+clean:
+	$(RM) -r build
 
 dist:
 	@echo "Generating $(VER).tgz";\


