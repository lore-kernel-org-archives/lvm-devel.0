From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon,  8 Mar 2021 13:12:32 +0000 (GMT)
Subject: main - makefiles: Revert most of 456b659
Message-ID: <20210308131232.41E6D394EC02@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e10633394d64d5a1d2434fb0166689bbfb732bef
Commit:        e10633394d64d5a1d2434fb0166689bbfb732bef
Parent:        2244a56021475179b8cc3633c8cb6534eaa18025
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Mar 8 13:59:26 2021 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Mar 8 13:59:26 2021 +0100

makefiles: Revert most of 456b659

Must not use DESTDIR with --basedir.

Reverts: 456b659b4edfc758b5aa0b72af25677a4f5042ea
---
 daemons/lvmdbusd/Makefile.in | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/daemons/lvmdbusd/Makefile.in b/daemons/lvmdbusd/Makefile.in
index 56d5c6602..dee37122a 100644
--- a/daemons/lvmdbusd/Makefile.in
+++ b/daemons/lvmdbusd/Makefile.in
@@ -15,7 +15,7 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-lvmdbusdir = $(DESTDIR)$(python3dir)/lvmdbusd
+lvmdbusdir = $(python3dir)/lvmdbusd
 
 LVMDBUS_SRCDIR_FILES = \
 	automatedproperties.py \
@@ -57,12 +57,12 @@ install_lvmdbusd: $(LVMDBUSD)
 	@echo "    [INSTALL] $<"
 	$(Q) $(INSTALL_DIR) $(sbindir)
 	$(Q) $(INSTALL_SCRIPT) $(LVMDBUSD) $(sbindir)
-	$(Q) $(INSTALL_DIR) $(lvmdbusdir)
-	$(Q) (cd $(srcdir); $(INSTALL_DATA) $(LVMDBUS_SRCDIR_FILES) $(lvmdbusdir))
-	$(Q) $(INSTALL_DATA) $(LVMDBUS_BUILDDIR_FILES) $(lvmdbusdir)
+	$(Q) $(INSTALL_DIR) $(DESTDIR)$(lvmdbusdir)
+	$(Q) (cd $(srcdir); $(INSTALL_DATA) $(LVMDBUS_SRCDIR_FILES) $(DESTDIR)$(lvmdbusdir))
+	$(Q) $(INSTALL_DATA) $(LVMDBUS_BUILDDIR_FILES) $(DESTDIR)$(lvmdbusdir)
 	$(Q) PYTHON=$(PYTHON3) $(PYCOMPILE) --destdir "$(DESTDIR)" --basedir "$(lvmdbusdir)" $(LVMDBUS_SRCDIR_FILES) $(LVMDBUS_BUILDDIR_FILES)
-	$(Q) $(CHMOD) 755 $(lvmdbusdir)/__pycache__
-	$(Q) $(CHMOD) 444 $(lvmdbusdir)/__pycache__/*.py[co]
+	$(Q) $(CHMOD) 755 $(DESTDIR)$(lvmdbusdir)/__pycache__
+	$(Q) $(CHMOD) 444 $(DESTDIR)$(lvmdbusdir)/__pycache__/*.py[co]
 
 install_lvm2: install_lvmdbusd
 


