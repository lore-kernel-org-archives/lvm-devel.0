From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  5 Dec 2013 13:19:17 +0000 (UTC)
Subject: master - compile/link: EXTRA_EXEC_CFLAGS must be applied for *.o
Message-ID: <20131205131917.8DAAB60D6C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a344466e26cf7611c84c2548999dc67080e28347
Commit:        a344466e26cf7611c84c2548999dc67080e28347
Parent:        481edce41f54a392b663991c4e29c9eed05f90b5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Dec 5 14:19:10 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Dec 5 14:19:10 2013 +0100

compile/link: EXTRA_EXEC_CFLAGS must be applied for *.o

---
 tools/Makefile.in |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/tools/Makefile.in b/tools/Makefile.in
index 34df48b..f18d3ea 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -121,8 +121,10 @@ LIBS += $(UDEV_LIBS) $(BLKID_LIBS)
 
 device-mapper: $(TARGETS_DM)
 
+CFLAGS_dmsetup.o += $(EXTRA_EXEC_CFLAGS)
+
 dmsetup: dmsetup.o $(top_builddir)/libdm/libdevmapper.$(LIB_SUFFIX)
-	$(CC) $(CFLAGS) $(EXTRA_EXEC_CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) -L$(top_builddir)/libdm \
+	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) -L$(top_builddir)/libdm \
 	      -o $@ dmsetup.o -ldevmapper $(LIBS)
 
 dmsetup.static: dmsetup.o $(interfacebuilddir)/libdevmapper.a
@@ -131,8 +133,10 @@ dmsetup.static: dmsetup.o $(interfacebuilddir)/libdevmapper.a
 
 all: device-mapper
 
+CFLAGS_lvm.o += $(EXTRA_EXEC_CFLAGS)
+
 lvm: $(OBJECTS) lvm.o $(top_builddir)/lib/liblvm-internal.a
-	$(CC) $(CFLAGS) $(EXTRA_EXEC_CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $(OBJECTS) lvm.o \
+	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $(OBJECTS) lvm.o \
 		$(LVMLIBS) $(READLINE_LIBS) $(LIBS) -rdynamic
 
 ifeq ("@BUILD_LVMETAD@", "yes")


