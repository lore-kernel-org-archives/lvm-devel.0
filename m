From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue,  2 Mar 2010 13:07:21 +0100
Subject: [PATCH 3/9] For Makefile vars use $() instead of ${}
In-Reply-To: <cover.1267529065.git.zkabelac@redhat.com>
References: <cover.1267529065.git.zkabelac@redhat.com>
Message-ID: <f838ab18e28c2fed78ec98512acbf04a098eb208.1267529065.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Both definitions are correct, but we should use one form
consistenly through all Makefiles.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/dmeventd/plugins/lvm2/Makefile.in     |    2 +-
 daemons/dmeventd/plugins/mirror/Makefile.in   |    4 ++--
 daemons/dmeventd/plugins/snapshot/Makefile.in |    4 ++--
 man/Makefile.in                               |    4 ++--
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/daemons/dmeventd/plugins/lvm2/Makefile.in b/daemons/dmeventd/plugins/lvm2/Makefile.in
index 96c60e0..af6807b 100644
--- a/daemons/dmeventd/plugins/lvm2/Makefile.in
+++ b/daemons/dmeventd/plugins/lvm2/Makefile.in
@@ -16,7 +16,7 @@ top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 VPATH = @srcdir@
 
-CLDFLAGS += -L${top_builddir}/tools
+CLDFLAGS += -L$(top_builddir)/tools
 
 SOURCES = dmeventd_lvm.c
 
diff --git a/daemons/dmeventd/plugins/mirror/Makefile.in b/daemons/dmeventd/plugins/mirror/Makefile.in
index a6af47f..bdb49d1 100644
--- a/daemons/dmeventd/plugins/mirror/Makefile.in
+++ b/daemons/dmeventd/plugins/mirror/Makefile.in
@@ -17,8 +17,8 @@ top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 VPATH = @srcdir@
 
-INCLUDES += -I${top_srcdir}/tools -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
-CLDFLAGS += -L${top_builddir}/tools -L${top_builddir}/daemons/dmeventd/plugins/lvm2
+INCLUDES += -I$(top_srcdir)/tools -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
+CLDFLAGS += -L$(top_builddir)/tools -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
 
 SOURCES = dmeventd_mirror.c
 
diff --git a/daemons/dmeventd/plugins/snapshot/Makefile.in b/daemons/dmeventd/plugins/snapshot/Makefile.in
index 133459d..4b203a0 100644
--- a/daemons/dmeventd/plugins/snapshot/Makefile.in
+++ b/daemons/dmeventd/plugins/snapshot/Makefile.in
@@ -17,8 +17,8 @@ top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 VPATH = @srcdir@
 
-INCLUDES += -I${top_srcdir}/tools -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
-CLDFLAGS += -L${top_builddir}/tools -L${top_builddir}/daemons/dmeventd/plugins/lvm2
+INCLUDES += -I$(top_srcdir)/tools -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
+CLDFLAGS += -L$(top_builddir)/tools -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
 
 SOURCES = dmeventd_snapshot.c
 
diff --git a/man/Makefile.in b/man/Makefile.in
index dfe95e6..b1b8596 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -43,8 +43,8 @@ ifeq ("@BUILD_CMIRRORD@", "yes")
 endif
 
 MAN8DM=dmsetup.8
-MAN5DIR=${mandir}/man5
-MAN8DIR=${mandir}/man8
+MAN5DIR=$(mandir)/man5
+MAN8DIR=$(mandir)/man8
 
 CLEAN_TARGETS=$(MAN5) $(MAN8) $(MAN8CLUSTER) $(FSADMMAN) $(MAN8DM)
 
-- 
1.7.0


