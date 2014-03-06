From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  6 Mar 2014 16:31:14 +0000 (UTC)
Subject: master - makefiles: link blkid library only to lvm
Message-ID: <20140306163114.1DC8160DF1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d5a00c459734e6db0f739764e853424379e8c767
Commit:        d5a00c459734e6db0f739764e853424379e8c767
Parent:        7a595d7388d2dfdb4253ef9425c812491c8e7af5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 6 16:26:18 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 6 17:30:10 2014 +0100

makefiles: link blkid library only to lvm

Don't add blkid to every linkage.
Link udev library just with lvm tools.
Drop extra linkage of udev library, since deps from libdevmapper
are already resolved in linked -ldevmapper.
---
 tools/Makefile.in |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/tools/Makefile.in b/tools/Makefile.in
index 253c404..1a8db36 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -118,11 +118,9 @@ CFLOW_TARGET = lvm
 
 include $(top_builddir)/make.tmpl
 
-LIBS += $(UDEV_LIBS) $(BLKID_LIBS)
-
 device-mapper: $(TARGETS_DM)
 
-CFLAGS_dmsetup.o += $(EXTRA_EXEC_CFLAGS)
+CFLAGS_dmsetup.o += $(UDEV_CFLAGS) $(EXTRA_EXEC_CFLAGS)
 
 dmsetup: dmsetup.o $(top_builddir)/libdm/libdevmapper.$(LIB_SUFFIX)
 	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) -L$(top_builddir)/libdm \


