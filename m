From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 14 Dec 2018 09:17:39 -0500
Subject: master - makefiles: drop unneeded include path
Message-ID: <201812141417.wBEEHdQt010334@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=454024f9576e83dde7c2c2df9a201c3e680bd864
Commit:        454024f9576e83dde7c2c2df9a201c3e680bd864
Parent:        0f5bdd4d316c0651f170ba73eca244caf71d8e70
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 13:12:58 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 14 15:14:48 2018 +0100

makefiles: drop unneeded include path

---
 tools/Makefile.in |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/tools/Makefile.in b/tools/Makefile.in
index 4be1f72..7b29517 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -118,8 +118,6 @@ all: device-mapper
 
 CFLAGS_lvm.o += $(EXTRA_EXEC_CFLAGS)
 
-INCLUDES += -I$(top_builddir)/tools
-
 lvm: $(OBJECTS) lvm.o $(top_builddir)/lib/liblvm-internal.a $(INTERNAL_LIBS)
 	@echo "    [CC] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $+ \


