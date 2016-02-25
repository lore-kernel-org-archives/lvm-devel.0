From: Bryn Reeves <bmr@fedoraproject.org>
Date: Thu, 25 Feb 2016 16:51:48 +0000 (UTC)
Subject: master - tests: install does not depend on lib/version-expected
Message-ID: <20160225165148.27FE560204@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d4a5c252c59fb22d705fc0978ccf0d7cf2a69ba7
Commit:        d4a5c252c59fb22d705fc0978ccf0d7cf2a69ba7
Parent:        2d630ea78aa430608f914e6da37fb98b051d86fa
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Dec 11 13:17:08 2015 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Feb 25 16:40:59 2016 +0000

tests: install does not depend on lib/version-expected

The install target already depends on .tests-stamp - since this
in turn depends on lib/version-expected there is no need to have
this as a dependency of install.
---
 test/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index c69b3b6..fdae254 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -199,7 +199,7 @@ LIB_NOT = not
 LIB_LINK_NOT = invalid fail should
 LIB_SHARED = check aux inittest utils get lvm-wrapper
 
-install: .tests-stamp lib/paths-installed lib/version-expected
+install: .tests-stamp lib/paths-installed
 	@echo $(srcdir)
 	$(INSTALL_DIR) $(DATADIR)/{shell,api,lib} $(EXECDIR)
 	$(INSTALL_DATA) shell/*.sh $(DATADIR)/shell


