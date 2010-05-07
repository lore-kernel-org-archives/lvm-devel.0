From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  7 May 2010 16:14:50 +0200
Subject: [PATCH 3/9] Fix linking libdevmapper-event.so
In-Reply-To: <cover.1273241256.git.zkabelac@redhat.com>
References: <cover.1273241256.git.zkabelac@redhat.com>
Message-ID: <0811f42cc975560dc399366eebfe761b9b1493bd.1273241256.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As for now LIB_SHARED links $(LIBS) so use this to add .so dependency on
libdevmapper.so during creation of shared library.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/dmeventd/Makefile.in |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index fb4f8f5..f9afdb6 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -53,7 +53,8 @@ include $(top_builddir)/make.tmpl
 all: device-mapper
 device-mapper: $(TARGETS)
 
-LVMLIBS += -ldevmapper-event -ldevmapper $(PTHREAD_LIBS)
+LIBS += -ldevmapper
+LVMLIBS += -ldevmapper-event $(PTHREAD_LIBS)
 
 dmeventd: $(LIB_SHARED) dmeventd.o
 	$(CC) $(CFLAGS) $(LDFLAGS) -L. -o $@ dmeventd.o \
-- 
1.7.0.1


