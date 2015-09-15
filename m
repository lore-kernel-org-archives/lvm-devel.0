From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 15 Sep 2015 12:14:37 +0000 (UTC)
Subject: master - man: Add all_man Makefile target.
Message-ID: <20150915121437.4BBA461084@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=548c09acfca8970cafe74f43e1944b5f20f540be
Commit:        548c09acfca8970cafe74f43e1944b5f20f540be
Parent:        2ce8ee0214c84a4afd12589bbe2fe521c2518b87
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Sep 15 13:14:16 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Sep 15 13:14:16 2015 +0100

man: Add all_man Makefile target.

Use 'make all_man' to generate all man pages (regardless of
configuration options) or 'make install_all_man' to install them.
---
 Makefile.in     |    7 +++++--
 WHATS_NEW       |    1 +
 make.tmpl.in    |    2 +-
 man/Makefile.in |   14 ++++++++++++--
 4 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index d9ac815..68fbc79 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -131,6 +131,9 @@ rpm: dist
 generate: conf.generate
 	$(MAKE) -C conf generate
 
+all_man:
+	$(MAKE) -C man all_man
+
 install_system_dirs:
 	$(INSTALL_DIR) $(DESTDIR)$(DEFAULT_SYS_DIR)
 	$(INSTALL_ROOT_DIR) $(DESTDIR)$(DEFAULT_ARCHIVE_DIR)
@@ -150,8 +153,8 @@ install_systemd_generators:
 install_systemd_units:
 	$(MAKE) -C scripts install_systemd_units
 
-install_full_man:
-	$(MAKE) -C man install_full_man
+install_all_man:
+	$(MAKE) -C man install_all_man
 
 ifeq ("@PYTHON_BINDINGS@", "yes")
 install_python_bindings:
diff --git a/WHATS_NEW b/WHATS_NEW
index c661702..8f87617 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.131 - 
 =====================================
+  Rename 'make install_full_man' to install_all_man and add all_man target.
   Fix vgimportclone cache_dir path name (2.02.115).
   Swapping of LV identifiers handles more complex LVs.
   Use passed list of PVS when allocating space in lvconvert --thinpool.
diff --git a/make.tmpl.in b/make.tmpl.in
index 7124144..1217278 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -275,7 +275,7 @@ POTFILES = $(SOURCES:%.c=%.pot)
 .PHONY: all pofile distclean clean cleandir cflow device-mapper
 .PHONY: install install_cluster install_device-mapper install_lvm2
 .PHONY: install_lib_shared install_dm_plugin install_lvm2_plugin
-.PHONY: install_ocf install_systemd_generators install_full_man help
+.PHONY: install_ocf install_systemd_generators install_all_man all_man man help
 .PHONY: python_bindings install_python_bindings
 .PHONY: $(SUBDIRS) $(SUBDIRS.install) $(SUBDIRS.clean) $(SUBDIRS.distclean)
 .PHONY: $(SUBDIRS.pofile) $(SUBDIRS.install_cluster) $(SUBDIRS.cflow)
diff --git a/man/Makefile.in b/man/Makefile.in
index 6ddbaa9..6ef7186 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -42,7 +42,15 @@ MAN8DM=dmsetup.8 dmstats.8
 MAN8CLUSTER=
 MAN8SYSTEMD_GENERATORS=lvm2-activation-generator.8
 
-ifeq ($(MAKECMDGOALS),install_full_man)
+ifeq ($(MAKECMDGOALS),all_man)
+  MAN_ALL="yes"
+endif
+
+ifeq ($(MAKECMDGOALS),install_all_man)
+  MAN_ALL="yes"
+endif
+
+ifeq ($(MAN_ALL),"yes")
   MAN8+=$(FSADMMAN) $(LVMETADMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN)
   MAN8DM+=$(BLKDEACTIVATEMAN) $(DMEVENTDMAN)
   MAN8CLUSTER+=$(CLVMDMAN) $(CMIRRORDMAN)
@@ -109,6 +117,8 @@ device-mapper: $(MAN8DM)
 
 man: $(MAN5) $(MAN7) $(MAN8) $(MAN8CLUSTER) $(MAN8SYSTEMD_GENERATORS)
 
+all_man: man
+
 $(MAN5) $(MAN7) $(MAN8) $(MAN8DM) $(MAN8CLUSTER):	Makefile
 
 Makefile: Makefile.in
@@ -150,4 +160,4 @@ install_systemd_generators: $(MAN8SYSTEMD_GENERATORS)
 
 install: install_lvm2 install_device-mapper install_cluster
 
-install_full_man: install install_systemd_generators
+install_all_man: install install_systemd_generators


