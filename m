From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  1 Aug 2012 06:43:26 +0000 (UTC)
Subject: master - make: use proper libs to make scripts subdir
Message-ID: <20120801064326.347CB3192@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c6cc871df845ea4c810122a59606c3c593d15772
Commit:        c6cc871df845ea4c810122a59606c3c593d15772
Parent:        fa68466e904568d054f0b0cf5fdab6499cb47998
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Aug 1 08:40:36 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Aug 1 08:42:49 2012 +0200

make: use proper libs to make scripts subdir

---
 scripts/Makefile.in |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 40396b0..2298f0c 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -21,8 +21,13 @@ TARGETS = lvm2_activation_generator_systemd_red_hat
 include $(top_builddir)/make.tmpl
 
 DEPLIBS += $(top_builddir)/liblvm/liblvm2app.so $(top_builddir)/libdm/libdevmapper.so
+LDFLAGS += -L$(top_builddir)/liblvm
 LVMLIBS = @LVM2APP_LIB@ -ldevmapper
 
+ifeq ("@DMEVENTD@", "yes")
+	LVMLIBS += -ldevmapper-event
+endif
+
 SCRIPTS = lvmdump.sh lvmconf.sh vgimportclone.sh
 
 ifeq ("@FSADM@", "yes")
@@ -67,7 +72,7 @@ ifeq ("@BUILD_CMIRRORD@", "yes")
 endif
 
 lvm2_activation_generator_systemd_red_hat: $(OBJECTS) $(DEPLIBS)
-	$(CC) -o $@ $(OBJECTS) $(LVMLIBS)
+	$(CC) -o $@ $(OBJECTS) $(LDFLAGS) $(LVMLIBS)
 
 install_systemd_generators:
 	$(INSTALL_DIR) $(systemd_generator_dir)


