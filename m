From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  7 Jan 2011 12:17:29 +0100
Subject: [PATCH 1/8] Add support for OCF dir selection
In-Reply-To: <cover.1294398815.git.zkabelac@redhat.com>
References: <cover.1294398815.git.zkabelac@redhat.com>
Message-ID: <db275a73b7fcc40a9be28bc0a1235319042355ac.1294398815.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add --with-ocfdir supported configure option.
Fixes also superfluous '/usr' in 'ocf_scriptdir'.

Note: After commit regeneration of configure file is needed.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 configure.in |    5 +++++
 make.tmpl.in |    2 +-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/configure.in b/configure.in
index 6cb5e8d..b58a6ba 100644
--- a/configure.in
+++ b/configure.in
@@ -368,6 +368,10 @@ AC_ARG_ENABLE(ocf,
 			     [enable Open Cluster Framework (OCF) compliant resource agents]),
 	      OCF=$enableval, OCF=no)
 AC_MSG_RESULT($OCF)
+AC_ARG_WITH(ocfdir,
+	    AC_HELP_STRING([--with-ocfdir=DIR],
+			   [install OCF files in DIR [[PREFIX/lib/ocf/resource.d/lvm2]]]),
+	    OCFDIR=$withval, OCFDIR='${prefix}/lib/ocf/resource.d/lvm2')
 
 ################################################################################
 dnl -- Init pkg-config with dummy invokation:
@@ -1328,6 +1332,7 @@ AC_SUBST(LVM_RELEASE)
 AC_SUBST(LVM_RELEASE_DATE)
 AC_SUBST(MIRRORS)
 AC_SUBST(OCF)
+AC_SUBST(OCFDIR)
 AC_SUBST(REPLICATORS)
 AC_SUBST(MSGFMT)
 AC_SUBST(PKGCONFIG)
diff --git a/make.tmpl.in b/make.tmpl.in
index 806f77a..48fd617 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -65,7 +65,7 @@ staticdir = $(DESTDIR)@STATICDIR@
 udevdir = $(DESTDIR)@udevdir@
 pkgconfigdir = $(usrlibdir)/pkgconfig
 initdir = $(DESTDIR)@sysconfdir@/rc.d/init.d
-ocf_scriptdir = $(DESTDIR)@prefix@/usr/lib/ocf/resource.d/lvm2
+ocf_scriptdir = $(DESTDIR)@OCFDIR@
 
 USRLIB_RELPATH = $(shell echo $(abspath $(usrlibdir) $(libdir)) | \
   $(AWK) -f $(top_srcdir)/scripts/relpath.awk)
-- 
1.7.3.4


