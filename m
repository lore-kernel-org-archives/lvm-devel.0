From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 22 Apr 2023 09:26:28 +0000 (GMT)
Subject: main - makefiles: forgotten to install some test config
Message-ID: <20230422092628.B7B393858C74@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f239ce2353504f1a69fd7cc5386067cffd71b965
Commit:        f239ce2353504f1a69fd7cc5386067cffd71b965
Parent:        1f4e3832e0b6c877857e26f50aaa7196d9034cca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 22 11:21:46 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Apr 22 11:25:39 2023 +0200

makefiles: forgotten to install some test config

rpm testing missed config files.
---
 test/Makefile.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 1ea797d85..bb6167ea5 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -234,7 +234,7 @@ install: .tests-stamp lib/paths-installed
 	$(Q)- $(INSTALL_PROGRAM) dbus/*.py $(DATADIR)/dbus/
 	$(Q) $(INSTALL_DATA) lib/paths-installed $(DATADIR)/lib/paths
 	$(Q) cd lib &&\
-		$(INSTALL_DATA) $(LIB_DATA) $(DATADIR)/lib
+		$(INSTALL_DATA) $(LIB_DATA) $(LIB_CONF) $(DATADIR)/lib
 	$(Q) cd lib &&\
 		$(INSTALL_SCRIPT) $(LIB_SHARED) $(DATADIR)/lib
 	$(Q) cd lib &&\

