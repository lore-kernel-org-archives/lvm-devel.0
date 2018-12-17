From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Dec 2018 05:08:28 -0500
Subject: master - makefiles: quite install
Message-ID: <201812171008.wBHA8SFD024790@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f619cac598e9236dd16c7fd8d3465b981c4a4648
Commit:        f619cac598e9236dd16c7fd8d3465b981c4a4648
Parent:        a63015442e8bf3893e8531b209057a44158e438b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 15 01:47:24 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 17 10:36:52 2018 +0100

makefiles: quite install

---
 conf/Makefile.in    |    9 +++++----
 scripts/Makefile.in |    5 +++--
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/conf/Makefile.in b/conf/Makefile.in
index e906835..dc74747 100644
--- a/conf/Makefile.in
+++ b/conf/Makefile.in
@@ -39,18 +39,19 @@ generate:
 install_conf: $(CONFSRC)
 	@if [ ! -e $(confdir)/$(CONFDEST) ]; then \
 		echo "$(INSTALL_WDATA) -D $< $(confdir)/$(CONFDEST)"; \
-		$(INSTALL_WDATA) -D $< $(confdir)/$(CONFDEST); \
+		$(Q) $(INSTALL_WDATA) -D $< $(confdir)/$(CONFDEST); \
 	fi
 
 install_localconf: $(CONFLOCAL)
 	@if [ ! -e $(confdir)/$(CONFLOCAL) ]; then \
 		echo "$(INSTALL_WDATA) -D $< $(confdir)/$(CONFLOCAL)"; \
-		$(INSTALL_WDATA) -D $< $(confdir)/$(CONFLOCAL); \
+		$(Q) $(INSTALL_WDATA) -D $< $(confdir)/$(CONFLOCAL); \
 	fi
 
 install_profiles: $(PROFILES)
-	$(INSTALL_DIR) $(profiledir)
-	$(INSTALL_DATA) $(PROFILES) $(profiledir)/
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_DIR) $(profiledir)
+	$(Q) $(INSTALL_DATA) $(PROFILES) $(profiledir)/
 
 install_lvm2: install_conf install_localconf install_profiles
 
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 99acfbc..6c8546d 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -124,8 +124,9 @@ install_systemd_units:	install_dbus_service
 endif
 
 install_tmpfiles_configuration:
-	$(INSTALL_DIR) $(tmpfiles_dir)
-	$(INSTALL_DATA) lvm2_tmpfiles_red_hat.conf $(tmpfiles_dir)/lvm2.conf
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_DIR) $(tmpfiles_dir)
+	$(Q) $(INSTALL_DATA) lvm2_tmpfiles_red_hat.conf $(tmpfiles_dir)/lvm2.conf
 
 DISTCLEAN_TARGETS += \
 	blkdeactivate.sh \


