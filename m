From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  9 Oct 2013 22:36:31 +0000 (UTC)
Subject: master - libdm: Link to libpthread unconditionally.
Message-ID: <20131009223631.6F68C610C2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=529a13ec8907d5693b64ca7063491db059533820
Commit:        529a13ec8907d5693b64ca7063491db059533820
Parent:        7bed6d1263c5a65dbdf8e6d6ead021009aa9a59a
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Oct 10 00:27:53 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Oct 10 00:34:35 2013 +0200

libdm: Link to libpthread unconditionally.

---
 configure.in      |    6 ++----
 libdm/Makefile.in |    2 +-
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/configure.in b/configure.in
index 611ab37..3bd2439 100644
--- a/configure.in
+++ b/configure.in
@@ -1181,10 +1181,8 @@ Features cannot be 'shared' when building statically
 fi
 
 ################################################################################
-if [[ "$DMEVENTD" = yes -o "$CLVMD" != none ]] ; then
-	AC_CHECK_LIB([pthread], [pthread_mutex_lock],
-		[PTHREAD_LIBS="-lpthread"], hard_bailout)
-fi
+AC_CHECK_LIB([pthread], [pthread_mutex_lock],
+	[PTHREAD_LIBS="-lpthread"], hard_bailout)
 
 ################################################################################
 dnl -- Disable selinux
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index bddb0a0..2aa70d4 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -57,7 +57,7 @@ include $(top_builddir)/make.tmpl
 DEFS += -DDM_DEVICE_UID=@DM_DEVICE_UID@ -DDM_DEVICE_GID=@DM_DEVICE_GID@ \
 	-DDM_DEVICE_MODE=@DM_DEVICE_MODE@
 
-LIBS += $(SELINUX_LIBS) $(UDEV_LIBS)
+LIBS += $(SELINUX_LIBS) $(UDEV_LIBS) $(PTHREAD_LIBS)
 
 device-mapper: all
 


