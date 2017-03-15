From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 14 Mar 2017 21:32:57 -0400
Subject: master - make: Support for 'make -R'.
Message-ID: <201703150132.v2F1WvcB032246@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1dc1a1cedb5ba3d9f48d2d5915145c3fdabf6cb7
Commit:        1dc1a1cedb5ba3d9f48d2d5915145c3fdabf6cb7
Parent:        531d7c97e7e48a3874448794e724c814ad662114
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Mar 15 01:31:11 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Mar 15 01:31:11 2017 +0000

make: Support for 'make -R'.

Aim to be self-sufficient.
---
 make.tmpl.in |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 2e7c1ba..2af1b1c 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -44,6 +44,8 @@ EGREP = @EGREP@
 GREP = @GREP@
 SORT = @SORT@
 WC = @WC@
+AR = ar
+RM = rm -f
 
 PYTHON2 = @PYTHON2@
 PYTHON3 = @PYTHON3@
@@ -156,6 +158,7 @@ INSTALL_ROOT_DIR = $(INSTALL) -m 700 -d
 INSTALL_ROOT_DATA = $(INSTALL) -m 600
 INSTALL_SCRIPT = $(INSTALL) -p $(M_INSTALL_PROGRAM)
 
+.SUFFIXES:
 .SUFFIXES: .c .cpp .d .o .so .a .po .pot .mo .dylib
 
 WFLAGS +=\
@@ -410,6 +413,8 @@ cflow: $(CFLOW_TARGET).cflow $(CFLOW_TARGET).tree $(CFLOW_TARGET).rxref $(CFLOW_
 endif
 endif
 
+.LIBPATTERNS = lib%.so lib%.a
+
 %.o: %.c
 	$(CC) -c $(INCLUDES) $(DEFS) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
 
@@ -461,7 +466,7 @@ endif
 
 $(LIB_STATIC): $(OBJECTS)
 	$(RM) $@
-	$(AR) rs $@ $(OBJECTS)
+	$(AR) rsv $@ $(OBJECTS)
 
 %.d: %.c $(INC_LNS)
 	$(MKDIR_P) $(dir $@); \


