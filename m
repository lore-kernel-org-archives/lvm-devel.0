From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 31 May 2019 03:14:21 -0400
Subject: master - test: Restore testing of D-Bus API
Message-ID: <201905310714.x4V7ELG6025441@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a9907bef9980dfe953a812e52760c174472ad0a6
Commit:        a9907bef9980dfe953a812e52760c174472ad0a6
Parent:        eebb5e9fffd4602b0455ed9729b4b3d4d341bc1c
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu May 30 18:02:55 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri May 31 08:58:30 2019 +0200

test: Restore testing of D-Bus API

---
 test/Makefile.in |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 69e2cfc..fcb612d 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -49,9 +49,9 @@ include $(top_builddir)/make.tmpl
 T ?= .
 S ?= @ # never match anything by default
 VERBOSE ?= 0
-ALL := $(shell find -L $(srcdir) \( -path \*/shell/\*.sh -or -path \*/unit/\*.sh \) | $(SORT))
+ALL := $(shell find -L $(srcdir) \( -path \*/shell/\*.sh -or -path \*/api/\*.sh -or -path \*/unit/\*.sh \) | $(SORT))
 comma = ,
-RUN := $(shell find -L $(srcdir) -regextype posix-egrep \( -path \*/shell/\*.sh -or -path \*/unit/\*.sh \) -and -regex "$(srcdir)/.*($(subst $(comma),|,$(T))).*" -and -not -regex "$(srcdir)/.*($(subst $(comma),|,$(S))).*" | $(SORT))
+RUN := $(shell find -L $(srcdir) -regextype posix-egrep \( -path \*/shell/\*.sh -or -path \*/api/\*.sh -or -path \*/unit/\*.sh \) -and -regex "$(srcdir)/.*($(subst $(comma),|,$(T))).*" -and -not -regex "$(srcdir)/.*($(subst $(comma),|,$(S))).*" | $(SORT))
 RUN_BASE = $(subst $(srcdir)/,,$(RUN))
 
 ifeq ("@BUILD_LVMPOLLD@", "yes")
@@ -200,8 +200,9 @@ LIB_SHARED = check aux inittest utils get lvm-wrapper
 
 install: .tests-stamp lib/paths-installed
 	@echo $(srcdir)
-	$(Q) $(INSTALL_DIR) $(DATADIR)/{shell,unit,lib,dbus} $(EXECDIR)
+	$(Q) $(INSTALL_DIR) $(DATADIR)/{shell,api,unit,lib,dbus} $(EXECDIR)
 	$(Q) $(INSTALL_DATA) shell/*.sh $(DATADIR)/shell
+	$(INSTALL_DATA) api/*.sh $(DATADIR)/api
 	$(Q) $(INSTALL_DATA) unit/*.sh $(DATADIR)/unit
 	-$(Q) $(INSTALL_PROGRAM) unit/unit-test $(DATADIR)/unit
 	-$(Q) $(INSTALL_PROGRAM) dbus/*.py $(DATADIR)/dbus/
@@ -291,7 +292,7 @@ lib/paths-installed: lib/paths-common
 	$(Q) $(RM) $@-t
 	$(Q) cat lib/paths-common > $@-t
 	$(Q) echo 'installed_testsuite=1' >> $@-t
-	$(Q) echo 'export PATH=@libexecdir@/lvm2-testsuite:@datadir@/lvm2-testsuite/lib:$$PATH' >> $@-t
+	$(Q) echo 'export PATH=@libexecdir@/lvm2-testsuite:@datadir@/lvm2-testsuite/lib:@datadir@/lvm2-testsuite/api:$$PATH' >> $@-t
 	$(Q) mv $@-t $@
 
 lib/paths: lib/paths-common


