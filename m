From: Bryn Reeves <bmr@sourceware.org>
Date: Fri, 10 Mar 2017 12:36:57 -0500
Subject: master - daemons: cleanup dmeventd references from dmfilemapd/Makefile.in
Message-ID: <201703101736.v2AHavg0019165@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b17eb054cd79d26573bf8a9ad1621dd1026cb11d
Commit:        b17eb054cd79d26573bf8a9ad1621dd1026cb11d
Parent:        5e6ea4b7844c81affd8521902eac9808bfe29232
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Mar 10 17:12:04 2017 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Mar 10 17:26:47 2017 +0000

daemons: cleanup dmeventd references from dmfilemapd/Makefile.in

---
 daemons/dmfilemapd/Makefile.in |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/daemons/dmfilemapd/Makefile.in b/daemons/dmfilemapd/Makefile.in
index 98fb9a8..28326d2 100644
--- a/daemons/dmfilemapd/Makefile.in
+++ b/daemons/dmfilemapd/Makefile.in
@@ -19,7 +19,7 @@ SOURCES = dmfilemapd.c
 
 TARGETS = dmfilemapd
 
-.PHONY: install_dmeventd install_dmeventd_static
+.PHONY: install_dmfilemapd install_dmfilemapd_static
 
 INSTALL_DMFILEMAPD_TARGETS = install_dmfilemapd_dynamic
 
@@ -35,9 +35,8 @@ all: device-mapper
 device-mapper: $(TARGETS)
 
 LIBS += -ldevmapper
-LVMLIBS += -ldevmapper-event $(PTHREAD_LIBS)
 
-CFLAGS_dmeventd.o += $(EXTRA_EXEC_CFLAGS)
+CFLAGS_dmfilemapd.o += $(EXTRA_EXEC_CFLAGS)
 
 dmfilemapd: $(LIB_SHARED) dmfilemapd.o
 	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -L. -o $@ dmfilemapd.o \


