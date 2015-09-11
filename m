From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Sep 2015 19:54:37 +0000 (UTC)
Subject: master - makefiles: distclean missing files
Message-ID: <20150911195437.7F741609C4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fd3d795b9301dd1defd33e4340fd453e5aee4e8d
Commit:        fd3d795b9301dd1defd33e4340fd453e5aee4e8d
Parent:        729b035edd923554275ac7b3bc446b57f0e9f0d5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 11 21:30:45 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 11 21:52:27 2015 +0200

makefiles: distclean missing files

---
 daemons/lvmetad/Makefile.in |    2 ++
 scripts/Makefile.in         |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmetad/Makefile.in b/daemons/lvmetad/Makefile.in
index 090bb76..ce7e5d6 100644
--- a/daemons/lvmetad/Makefile.in
+++ b/daemons/lvmetad/Makefile.in
@@ -45,6 +45,8 @@ lvmetactl: lvmetactl.o $(top_builddir)/libdaemon/client/libdaemonclient.a \
 	$(top_builddir)/libdaemon/server/libdaemonserver.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ lvmetactl.o $(LVMLIBS)
 
+CLEAN_TARGETS += lvmetactl.o
+
 # TODO: No idea. No idea how to test either.
 #ifneq ("$(CFLOW_CMD)", "")
 #CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 2ae5325..dabe2ee 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -151,6 +151,7 @@ DISTCLEAN_TARGETS += \
 	lvm2_clvmd_systemd_red_hat.service \
 	lvm2_cmirrord_systemd_red_hat.service \
 	lvm2_lvmetad_init_red_hat \
+	lvm2_lvmpolld_init_red_hat \
 	lvm2_lvmetad_systemd_red_hat.service \
 	lvm2_lvmetad_systemd_red_hat.socket \
 	lvm2_lvmpolld_systemd_red_hat.service \


