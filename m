From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  4 Jan 2013 23:48:23 +0000 (UTC)
Subject: master - lvmetad: lvm depends on libdaemonclient.a
Message-ID: <20130104234824.201D2231A@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a527a3b8c25200284824cd43ec7693d5543741a4
Commit:        a527a3b8c25200284824cd43ec7693d5543741a4
Parent:        ad85b0c526b40a4e78ac83426f54c935c147c787
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jan 4 23:10:38 2013 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jan 4 23:10:38 2013 +0000

lvmetad: lvm depends on libdaemonclient.a

Rebuild lvm binary if libdaemonclient.a changes.
---
 tools/Makefile.in |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/tools/Makefile.in b/tools/Makefile.in
index 15843f0..96dd8cf 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -135,6 +135,10 @@ lvm: $(OBJECTS) lvm.o $(top_builddir)/lib/liblvm-internal.a
 	$(CC) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) -o $@ $(OBJECTS) lvm.o \
 		$(LVMLIBS) $(READLINE_LIBS) $(LIBS) -rdynamic
 
+ifeq ("@BUILD_LVMETAD@", "yes")
+lvm: $(top_builddir)/libdaemon/client/libdaemonclient.a
+endif
+
 lvm.static: $(OBJECTS) lvm-static.o $(top_builddir)/lib/liblvm-internal.a  $(interfacebuilddir)/libdevmapper.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) -o $@ \
 	      $(OBJECTS) lvm-static.o $(LVMLIBS) $(STATIC_LIBS) $(LIBS)


