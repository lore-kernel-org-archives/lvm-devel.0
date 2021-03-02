From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:19 +0000 (GMT)
Subject: main - makefiles: cmirrord install through install_cluster
Message-ID: <20210302215819.F1DC13851C35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4e976d9960f28278563ba7d0cd4c3795a4eba949
Commit:        4e976d9960f28278563ba7d0cd4c3795a4eba949
Parent:        e080e35c839ab7c166acfc40b03beb7c1c1b2e56
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 2 00:23:45 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:54:40 2021 +0100

makefiles: cmirrord install through install_cluster

There is not much left for this target...
---
 daemons/cmirrord/Makefile.in | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/daemons/cmirrord/Makefile.in b/daemons/cmirrord/Makefile.in
index ff45225cd..301e6c6a2 100644
--- a/daemons/cmirrord/Makefile.in
+++ b/daemons/cmirrord/Makefile.in
@@ -33,6 +33,8 @@ cmirrord: $(OBJECTS)
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) \
 		$(LMLIBS) -L$(top_builddir)/libdm -ldevmapper $(LIBS)
 
-install: $(TARGETS)
+install_cluster: $(TARGETS)
 	@echo "    [INSTALL] $<"
-	$(Q) $(INSTALL_PROGRAM) -D cmirrord $(usrsbindir)/cmirrord
+	$(Q) $(INSTALL_PROGRAM) -D $< $(usrsbindir)/$(<F)
+
+install: install_cluster


