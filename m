From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:16 +0000 (GMT)
Subject: main - makefiles: drop invalid dependency on all
Message-ID: <20210302215816.8EC333851C35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=da29afe028c9709b5590a58bd727d1150df6a5ae
Commit:        da29afe028c9709b5590a58bd727d1150df6a5ae
Parent:        5509e764f1c542768b2dd5e39d2b900a96a3b281
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 28 01:20:28 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:54:40 2021 +0100

makefiles: drop invalid dependency on all

---
 make.tmpl.in | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 35d8267df..2346bfda2 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -337,8 +337,8 @@ LVMINTERNAL_LIBS = $(top_builddir)/lib/liblvm-internal.a $(INTERNAL_LIBS)
 
 all: $(SUBDIRS) $(TARGETS)
 
-install: all $(SUBDIRS.install)
-install_cluster: all $(SUBDIRS.install_cluster)
+install: $(SUBDIRS.install)
+install_cluster: $(SUBDIRS.install_cluster)
 install_device-mapper: $(SUBDIRS.install_device-mapper)
 install_device_mapper: install_device-mapper
 install_lvm2: $(SUBDIRS.install_lvm2)


