From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:12 +0000 (GMT)
Subject: main - makefiles: support help target
Message-ID: <20210302215812.0C5883851C35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9d190d6b4678f42de3285f7291caeec2f4a91cdb
Commit:        9d190d6b4678f42de3285f7291caeec2f4a91cdb
Parent:        8d3ce32880da0dc0e0d3b6b397cc3bddaf901dee
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 25 17:40:53 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:54:40 2021 +0100

makefiles: support help target

Usable targets for top-level make.
---
 Makefile.in | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/Makefile.in b/Makefile.in
index a5eb00442..095f1f447 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -154,6 +154,31 @@ install_all_man:
 install_tmpfiles_configuration:
 	$(MAKE) -C scripts install_tmpfiles_configuration
 
+help:
+	@echo -e "\nAvailable targets:"
+	@echo "  all			Default target."
+	@echo "  all_man		Build all man pages with generators."
+	@echo "  clean			Remove all compile files."
+	@echo "  device-mapper		Device mapper part of lvm2."
+	@echo "  dist			Generate distributable file."
+	@echo "  distclean		Remove all build files."
+	@echo "  generate		Generate man pages for sources."
+	@echo "  help			Display callable targets."
+	@echo "  install		Install all files."
+	@echo "  install_all_man	Install all man pages."
+	@echo "  install_cluster	Install cmirrord."
+	@echo "  install_device-mapper	Install device mapper files."
+	@echo "  install_initscripts	Install initialization scripts."
+	@echo "  install_lvm2		Install lvm2 files."
+	@echo "  install_systemd_units	Install systemd units."
+	@echo "  lcov			Generate lcov output."
+	@echo "  lcov-dated		Generate lcov with timedate suffix."
+	@echo "  lcov-reset		Reset lcov counters"
+	@echo "  man			Build man pages."
+	@echo "  rpm			Build rpm."
+	@echo "  run-unit-test		Run unit tests."
+	@echo "  tags			Generate c/etags."
+
 ifneq ("$(LCOV)", "")
 .PHONY: lcov-reset lcov lcov-dated
 


