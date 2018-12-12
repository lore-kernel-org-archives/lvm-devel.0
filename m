From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 12 Dec 2018 09:43:24 -0500
Subject: master - dmeventd: Fix libdevmapper-event linking
Message-ID: <201812121443.wBCEhOkL008026@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=46a8d2e898a48b1df86fe07d13df8aa994e32808
Commit:        46a8d2e898a48b1df86fe07d13df8aa994e32808
Parent:        627f0e2bd84753a7bfbda517f22c54a929e3a458
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Dec 12 10:50:36 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Dec 12 15:43:03 2018 +0100

dmeventd: Fix libdevmapper-event linking

---
 daemons/dmeventd/Makefile.in |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index 2d856f7..0a03d66 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -58,11 +58,12 @@ device-mapper: $(TARGETS)
 
 CFLAGS_dmeventd.o += $(EXTRA_EXEC_CFLAGS)
 LIBS += $(PTHREAD_LIBS)
+LIBS += $(INTERNAL_LIBS)
 
 dmeventd: $(LIB_SHARED) dmeventd.o
 	@echo "    [CC] $@"
 	$(Q) $(CC) $(CFLAGS) -L. $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) dmeventd.o \
-		-o $@ $(DL_LIBS) $(DMEVENT_LIBS) $(INTERNAL_LIBS) $(LIBS) -lm
+		-o $@ $(DL_LIBS) $(DMEVENT_LIBS) $(LIBS) -lm
 
 dmeventd.static: $(LIB_STATIC) dmeventd.o
 	@echo "    [CC] $@"


