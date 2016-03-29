From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Tue, 29 Mar 2016 06:26:17 +0000 (UTC)
Subject: master - test: Add missing directory
Message-ID: <20160329062617.06B7160DD2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bc0372cf9d0f7537c537b46b20703db21bc4a165
Commit:        bc0372cf9d0f7537c537b46b20703db21bc4a165
Parent:        d6e8f18e4d97ec8dc7ee5af98df10dffbcb25848
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Mar 29 08:24:52 2016 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Mar 29 08:24:52 2016 +0200

test: Add missing directory

Fix commit bb93a28bc1
---
 test/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index ded155d..d4c6b95 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -201,7 +201,7 @@ LIB_SHARED = check aux inittest utils get lvm-wrapper
 
 install: .tests-stamp lib/paths-installed
 	@echo $(srcdir)
-	$(INSTALL_DIR) $(DATADIR)/{shell,api,lib} $(EXECDIR)
+	$(INSTALL_DIR) $(DATADIR)/{shell,api,lib,dbus} $(EXECDIR)
 	$(INSTALL_DATA) shell/*.sh $(DATADIR)/shell
 	$(INSTALL_DATA) api/*.sh $(DATADIR)/api
 	$(INSTALL_PROGRAM) api/*.{t,py} $(DATADIR)/api


