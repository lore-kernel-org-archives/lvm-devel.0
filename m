From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 11 May 2015 13:54:07 +0000 (UTC)
Subject: master - makefile: cleanup after build
Message-ID: <20150511135407.B4A44603E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=62e7a6ca1a3479017b026c380a97c9f826b087da
Commit:        62e7a6ca1a3479017b026c380a97c9f826b087da
Parent:        fabc19b73cb08f1a80bbf558b858110520ee8b53
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 11 15:52:11 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 11 15:53:46 2015 +0200

makefile: cleanup after build

Provide cleaning rules for build dir and release tgz.
---
 Makefile.in |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 30c2c89..ac806bb 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -49,6 +49,8 @@ tools.distclean: test.distclean
 endif
 DISTCLEAN_DIRS += lcov_reports*
 DISTCLEAN_TARGETS += config.cache config.log config.status make.tmpl
+clean:
+	$(RM) -r build
 
 include make.tmpl
 
@@ -100,6 +102,7 @@ check check_system check_cluster check_local check_lvmetad unit: all
 conf.generate: tools
 
 VER = LVM2. at LVM_MAJOR@. at LVM_MINOR@. at LVM_PATCHLEVEL@
+CLEAN_TARGETS += $(VER).tgz
 
 dist:
 	@echo "Generating $(VER).tgz";\


