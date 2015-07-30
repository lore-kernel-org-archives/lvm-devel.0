From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Thu, 30 Jul 2015 18:40:17 +0000 (UTC)
Subject: master - test: Update Makefiles
Message-ID: <20150730184017.B6CD160D8A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0dae377fbf1e0b3e1484984602cbaf73487efa47
Commit:        0dae377fbf1e0b3e1484984602cbaf73487efa47
Parent:        8bc90a25c26baa3d31f46415b3bb61e46f0477c1
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Jul 30 20:23:14 2015 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Jul 30 20:39:38 2015 +0200

test: Update Makefiles

- Add missing check_lvmpolld to toplevel Makefile
- Document check_system
---
 Makefile.in      |    2 +-
 test/Makefile.in |    1 +
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 1eb026b..35e5d8f 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -95,7 +95,7 @@ endif
 DISTCLEAN_TARGETS += cscope.out
 CLEAN_DIRS += autom4te.cache
 
-check check_system check_cluster check_local check_lvmetad unit: all
+check check_system check_cluster check_local check_lvmetad check_lvmpolld unit: all
 	$(MAKE) -C test $(@)
 
 conf.generate: tools
diff --git a/test/Makefile.in b/test/Makefile.in
index 72eb4e6..65ba294 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -66,6 +66,7 @@ help:
 	@echo -e "\nAvailable targets:"
 	@echo "  all			Default target, run check."
 	@echo "  check			Run all tests."
+	@echo "  check_system		Run all tests using udev."
 	@echo "  check_local		Run tests without clvmd and lvmetad."
 	@echo "  check_cluster		Run tests with cluster daemon."
 	@echo "  check_lvmetad		Run tests with lvmetad daemon."


