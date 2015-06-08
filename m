From: David Teigland <teigland@fedoraproject.org>
Date: Mon,  8 Jun 2015 16:50:07 +0000 (UTC)
Subject: master - lvmetad, lvmpolld: remove DL_LIBS from Makefile
Message-ID: <20150608165007.3485960309@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fd29c7f3a171174dcd47eb8b23ff42a145cdacc6
Commit:        fd29c7f3a171174dcd47eb8b23ff42a145cdacc6
Parent:        7c312932215f8d70c4f6beb7db506898f4670cfe
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 8 11:48:22 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 8 11:48:22 2015 -0500

lvmetad, lvmpolld: remove DL_LIBS from Makefile

and rdynamic.  They are not needed.
---
 daemons/lvmetad/Makefile.in  |    3 +--
 daemons/lvmpolld/Makefile.in |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmetad/Makefile.in b/daemons/lvmetad/Makefile.in
index f9b997e..765128c 100644
--- a/daemons/lvmetad/Makefile.in
+++ b/daemons/lvmetad/Makefile.in
@@ -39,8 +39,7 @@ CFLAGS += $(EXTRA_EXEC_CFLAGS)
 
 lvmetad: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
 		    $(top_builddir)/libdaemon/server/libdaemonserver.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) \
-	$(DL_LIBS) $(LVMLIBS) $(LIBS) -rdynamic
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LVMLIBS) $(LIBS)
 
 # TODO: No idea. No idea how to test either.
 #ifneq ("$(CFLOW_CMD)", "")
diff --git a/daemons/lvmpolld/Makefile.in b/daemons/lvmpolld/Makefile.in
index 55f3dad..8ebbb90 100644
--- a/daemons/lvmpolld/Makefile.in
+++ b/daemons/lvmpolld/Makefile.in
@@ -38,8 +38,7 @@ CFLAGS += $(DAEMON_CFLAGS)
 
 lvmpolld: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
 		    $(top_builddir)/libdaemon/server/libdaemonserver.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) \
-	$(DL_LIBS) $(LVMLIBS) $(LIBS)
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LVMLIBS) $(LIBS)
 
 install_lvmpolld: lvmpolld
 	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)


