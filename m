From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  6 Apr 2021 20:07:29 +0000 (GMT)
Subject: main - makefiles: plugins can be build after shared library
Message-ID: <20210406200729.9EF793857823@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f1bfc0621b9d86349a1878c1e64e96c5c7040786
Commit:        f1bfc0621b9d86349a1878c1e64e96c5c7040786
Parent:        d2522f4a05aa027bcc911ecb832450bc19b7fb57
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 3 22:55:20 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 6 22:02:31 2021 +0200

makefiles: plugins can be build after shared library

---
 daemons/dmeventd/Makefile.in | 1 +
 1 file changed, 1 insertion(+)

diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index c737ca40d..d688a0d3b 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -64,6 +64,7 @@ include $(top_builddir)/make.tmpl
 
 all: device-mapper
 device-mapper: $(TARGETS)
+plugins.device-mapper: $(LIB_SHARED)
 
 CFLAGS_dmeventd.o += $(EXTRA_EXEC_CFLAGS)
 LIBS += $(PTHREAD_LIBS) -L$(top_builddir)/libdm -ldevmapper


