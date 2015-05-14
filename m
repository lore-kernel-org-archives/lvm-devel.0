From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 14 May 2015 13:02:00 +0000 (UTC)
Subject: master - makefiles: use srcdir
Message-ID: <20150514130200.891E66107C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a929606f2b5076f3cde546764664da4e39cefd56
Commit:        a929606f2b5076f3cde546764664da4e39cefd56
Parent:        679f1a9e29da5a1425ef7de857bd798bd211448c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 14 14:17:33 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 14 14:19:22 2015 +0200

makefiles: use srcdir

Use -I$(srcdir) as that's what we really want here.
For %.pot use all includes.
---
 make.tmpl.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 7ff61fd..4311490 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -274,7 +274,7 @@ LIB_VERSION_DM := $(shell $(AWK) -F '.' '{printf "%s.%s",$$1,$$2}' $(top_srcdir)
 
 LIB_VERSION_APP := $(shell $(AWK) -F '[(). ]' '{printf "%s.%s",$$1,$$4}' $(top_srcdir)/VERSION)
 
-INCLUDES += -I. -I$(top_builddir)/include
+INCLUDES += -I$(srcdir) -I$(top_builddir)/include
 
 INC_LNS = $(top_builddir)/include/.symlinks_created
 
@@ -414,7 +414,7 @@ endif
 	$(CXX) -c $(INCLUDES) $(DEFS) $(WFLAGS) $(CXXFLAGS) $(CXXFLAGS_$@) $< -o $@
 
 %.pot: %.c Makefile
-	$(CC) -E $(INCLUDES) -include $(top_builddir)/include/pogen.h \
+	$(CC) -E $(INCLUDES) $(BLKID_CFLAGS) $(VALGRIND_CFLAGS) $(UDEV_CFLAGS) -include $(top_builddir)/include/pogen.h \
 		$(DEFS) $(WFLAGS) $(CFLAGS) $< > $@
 
 %.so: %.o


