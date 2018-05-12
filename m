From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:27:00 -0400
Subject: master - build: install unit-test
Message-ID: <201805121627.w4CGR0kC008427@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=67c02877a1f2991e1f5de0205e20841b94df5413
Commit:        67c02877a1f2991e1f5de0205e20841b94df5413
Parent:        4c7565b65d0a02f6deedd37e1274b8646997fa71
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 12 00:05:01 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 18:18:23 2018 +0200

build: install unit-test

---
 test/Makefile.in |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 67f2753..407babd 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -226,11 +226,13 @@ LIB_SHARED = check aux inittest utils get lvm-wrapper
 
 install: .tests-stamp lib/paths-installed
 	@echo $(srcdir)
-	$(INSTALL_DIR) $(DATADIR)/{shell,api,lib,dbus} $(EXECDIR)
+	$(INSTALL_DIR) $(DATADIR)/{shell,api,unit,lib,dbus} $(EXECDIR)
 	$(INSTALL_DATA) shell/*.sh $(DATADIR)/shell
 	$(INSTALL_DATA) api/*.sh $(DATADIR)/api
+	$(INSTALL_DATA) unit/*.sh $(DATADIR)/unit
 	$(INSTALL_DATA) lib/mke2fs.conf $(DATADIR)/lib
 	$(INSTALL_PROGRAM) api/*.{t,py} $(DATADIR)/api
+	$(INSTALL_PROGRAM) unit/unit-test $(DATADIR)/unit
 	$(INSTALL_PROGRAM) dbus/*.py $(DATADIR)/dbus/
 	$(INSTALL_DATA) lib/paths-installed $(DATADIR)/lib/paths
 	cd lib && $(INSTALL_DATA) \


