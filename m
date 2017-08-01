From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 1 Aug 2017 06:02:02 -0400
Subject: master - makefiles: use gcc warns with gcc only
Message-ID: <201708011002.v71A22v8011561@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=918e867abe6a455a401346744820d9e54a977749
Commit:        918e867abe6a455a401346744820d9e54a977749
Parent:        57727bb4ebffb30cf21b151cc2f66bfd7d924a81
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 1 00:04:20 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 1 11:53:13 2017 +0200

makefiles: use gcc warns with gcc only

Avoid passing  'gcc' warning options to non-gcc compiler
---
 make.tmpl.in |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 2b2ddd1..102079e 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -163,6 +163,7 @@ INSTALL_SCRIPT = $(INSTALL) -p $(M_INSTALL_PROGRAM)
 .SUFFIXES:
 .SUFFIXES: .c .cpp .d .o .so .a .po .pot .mo .dylib
 
+ifeq ("$(notdir $(CC))", "gcc")
 WFLAGS +=\
  -Wall\
  -Wcast-align\
@@ -207,6 +208,7 @@ endif
 ifeq ("@HAVE_WSYNCNAND@", "yes")
 WFLAGS += -Wsync-nand
 endif
+endif
 
 ifneq ("@STATIC_LINK@", "yes")
 ifeq ("@HAVE_PIE@", "yes")


