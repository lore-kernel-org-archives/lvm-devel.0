From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:15 +0000 (GMT)
Subject: main - makefiles: add alias for device-mapper
Message-ID: <20210302215815.6EF793834402@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5509e764f1c542768b2dd5e39d2b900a96a3b281
Commit:        5509e764f1c542768b2dd5e39d2b900a96a3b281
Parent:        8d93d8b7b7f9ae90e56f171e694da0304ab3c6fe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 28 01:19:23 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:54:40 2021 +0100

makefiles: add alias for device-mapper

Support also 'make device_mapper' so user is less confused.
---
 Makefile.in        | 1 +
 libdm/make.tmpl.in | 1 +
 make.tmpl.in       | 1 +
 3 files changed, 3 insertions(+)

diff --git a/Makefile.in b/Makefile.in
index 095f1f447..a4278cade 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -66,6 +66,7 @@ daemons.device-mapper: libdm.device-mapper
 tools.device-mapper: libdm.device-mapper
 scripts.device-mapper: include.device-mapper
 device-mapper: tools.device-mapper daemons.device-mapper man.device-mapper
+device_mapper: device-mapper
 
 ifeq ("@INTL@", "yes")
 lib.pofile: include.pofile
diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index aaf8a5e77..4a32b8f94 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -310,6 +310,7 @@ all: $(SUBDIRS) $(TARGETS)
 
 install: all $(SUBDIRS.install)
 install_device-mapper: $(SUBDIRS.install_device-mapper)
+install_device_mapper: install_device-mapper
 cflow: $(SUBDIRS.cflow)
 
 $(SUBDIRS): $(SUBDIRS.device-mapper)
diff --git a/make.tmpl.in b/make.tmpl.in
index 4549746ab..35d8267df 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -340,6 +340,7 @@ all: $(SUBDIRS) $(TARGETS)
 install: all $(SUBDIRS.install)
 install_cluster: all $(SUBDIRS.install_cluster)
 install_device-mapper: $(SUBDIRS.install_device-mapper)
+install_device_mapper: install_device-mapper
 install_lvm2: $(SUBDIRS.install_lvm2)
 install_ocf: $(SUBDIRS.install_ocf)
 cflow: $(SUBDIRS.cflow)


