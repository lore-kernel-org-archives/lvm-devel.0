From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 18 Dec 2018 03:55:12 -0500
Subject: master - build: Remove badly placed `@`
Message-ID: <201812180855.wBI8tCM8020955@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=88153c7c0aa45e9ce3d8a226e5ba1b7af7002aa1
Commit:        88153c7c0aa45e9ce3d8a226e5ba1b7af7002aa1
Parent:        e0c2d374aeeb77258c3bcdf2bb3ec5a0fca95a97
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Dec 18 09:42:34 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Dec 18 09:54:47 2018 +0100

build: Remove badly placed `@`

---
 conf/Makefile.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/conf/Makefile.in b/conf/Makefile.in
index dc74747..ee3b032 100644
--- a/conf/Makefile.in
+++ b/conf/Makefile.in
@@ -39,13 +39,13 @@ generate:
 install_conf: $(CONFSRC)
 	@if [ ! -e $(confdir)/$(CONFDEST) ]; then \
 		echo "$(INSTALL_WDATA) -D $< $(confdir)/$(CONFDEST)"; \
-		$(Q) $(INSTALL_WDATA) -D $< $(confdir)/$(CONFDEST); \
+		$(INSTALL_WDATA) -D $< $(confdir)/$(CONFDEST); \
 	fi
 
 install_localconf: $(CONFLOCAL)
 	@if [ ! -e $(confdir)/$(CONFLOCAL) ]; then \
 		echo "$(INSTALL_WDATA) -D $< $(confdir)/$(CONFLOCAL)"; \
-		$(Q) $(INSTALL_WDATA) -D $< $(confdir)/$(CONFLOCAL); \
+		$(INSTALL_WDATA) -D $< $(confdir)/$(CONFLOCAL); \
 	fi
 
 install_profiles: $(PROFILES)


