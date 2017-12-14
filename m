From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 14 Dec 2017 10:53:32 -0500
Subject: master - lvmdbusd: Make lvmdbusd executable
Message-ID: <201712141553.vBEFrW0l011459@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c957d46f1d73891e3a7e9c1482c1d4a39ca0e79a
Commit:        c957d46f1d73891e3a7e9c1482c1d4a39ca0e79a
Parent:        c48d22bd3cddfe540413ed591ea18399c571a852
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Dec 14 13:40:05 2017 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Dec 14 16:45:53 2017 +0100

lvmdbusd: Make lvmdbusd executable

- Add files built from *.in to builddir files.
- Add all files built from *.in to DISTCLEAN_TARGETS.
---
 daemons/lvmdbusd/Makefile.in |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmdbusd/Makefile.in b/daemons/lvmdbusd/Makefile.in
index 0d52406..7cd7724 100644
--- a/daemons/lvmdbusd/Makefile.in
+++ b/daemons/lvmdbusd/Makefile.in
@@ -26,9 +26,7 @@ LVMDBUS_SRCDIR_FILES = \
 	__init__.py \
 	job.py \
 	loader.py \
-	lvmdb.py \
 	main.py \
-	lvm_shell_proxy.py \
 	lv.py \
 	manager.py \
 	objectmanager.py \
@@ -40,14 +38,19 @@ LVMDBUS_SRCDIR_FILES = \
 	vg.py
 
 LVMDBUS_BUILDDIR_FILES = \
+	lvmdb.py \
+	lvm_shell_proxy.py \
 	path.py
 
-LVMDBUSD = $(srcdir)/lvmdbusd
+LVMDBUSD = lvmdbusd
 
 include $(top_builddir)/make.tmpl
 
 .PHONY: install_lvmdbusd
 
+all:
+	test -x $(LVMDBUSD) || chmod 755 $(LVMDBUSD)
+
 install_lvmdbusd:
 	$(INSTALL_DIR) $(sbindir)
 	$(INSTALL_SCRIPT) $(LVMDBUSD) $(sbindir)
@@ -63,4 +66,5 @@ install_lvm2: install_lvmdbusd
 install: install_lvm2
 
 DISTCLEAN_TARGETS+= \
-	$(LVMDBUS_BUILDDIR_FILES)
+	$(LVMDBUS_BUILDDIR_FILES) \
+	$(LVMDBUSD)


