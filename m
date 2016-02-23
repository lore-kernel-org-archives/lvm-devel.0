From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Tue, 23 Feb 2016 17:37:23 +0000 (UTC)
Subject: master - make: Add check_lvmlockd_* targets to top-level
Message-ID: <20160223173723.5EFAC60F7F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=42da7a6c38ece2a9dca6492af1ba66ebaa9b6231
Commit:        42da7a6c38ece2a9dca6492af1ba66ebaa9b6231
Parent:        f54253d396d2f97d6f6a60185616523797364182
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Feb 23 18:34:46 2016 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Feb 23 18:34:46 2016 +0100

make: Add check_lvmlockd_* targets to top-level

---
 Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 1a63f9d..7557f62 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -95,7 +95,7 @@ endif
 DISTCLEAN_TARGETS += cscope.out
 CLEAN_DIRS += autom4te.cache
 
-check check_system check_cluster check_local check_lvmetad check_lvmpolld unit: all
+check check_system check_cluster check_local check_lvmetad check_lvmpolld check_lvmlockd_test check_lvmlockd_dlm check_lvmlockd_sanlock unit: all
 	$(MAKE) -C test $(@)
 
 conf.generate: tools


