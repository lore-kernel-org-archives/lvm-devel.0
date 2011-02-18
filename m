From: Miklos Vajna <vmiklos@frugalware.org>
Date: Fri, 18 Feb 2011 17:31:17 +0100
Subject: [PATCH] Add systemd service file
Message-ID: <20110218163117.GD5980@genesis.frugalware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I'm attaching a patch that installs a systemd service on make install.
See here for motivation:

http://article.gmane.org/gmane.comp.sysutils.systemd.devel/1289

The systemd-specific part is Ack'ed by Lennart.

Thanks.
-------------- next part --------------
>From 4e34b2d76428e244bcacb9554583290b2f08230f Mon Sep 17 00:00:00 2001
From: Miklos Vajna <vmiklos@frugalware.org>
Date: Fri, 18 Feb 2011 15:19:38 +0100
Subject: [PATCH] Add systemd service file

---
 Makefile.in         |    4 ++++
 configure.in        |   20 ++++++++++++++++++++
 make.tmpl.in        |    1 +
 systemd/Makefile.in |   16 ++++++++++++++++
 systemd/lvm.service |   15 +++++++++++++++
 5 files changed, 56 insertions(+), 0 deletions(-)
 create mode 100644 systemd/Makefile.in
 create mode 100644 systemd/lvm.service

diff --git a/Makefile.in b/Makefile.in
index f7e34f4..62fcbfc 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -22,6 +22,10 @@ ifeq ("@UDEV_RULES@", "yes")
   SUBDIRS += udev
 endif
 
+ifeq ("@SYSTEMD_SERVICE@", "yes")
+  SUBDIRS += systemd
+endif
+
 ifeq ("@INTL@", "yes")
   SUBDIRS += po
 endif
diff --git a/configure.in b/configure.in
index c531c8a..a6a2d21 100644
--- a/configure.in
+++ b/configure.in
@@ -818,6 +818,23 @@ AC_ARG_ENABLE(udev_rules,
 AC_MSG_RESULT($UDEV_RULES)
 
 ################################################################################
+dnl -- Enable systemd service
+PKG_PROG_PKG_CONFIG
+AC_MSG_CHECKING(systemd system unit directory)
+AC_ARG_WITH([systemdsystemunitdir],
+	    AS_HELP_STRING([--with-systemdsystemunitdir=DIR], [Directory for systemd service files]),
+	    [], [with_systemdsystemunitdir=$($PKG_CONFIG --variable=systemdsystemunitdir systemd)])
+if test "x$with_systemdsystemunitdir" != xno; then
+	AC_SUBST([systemdsystemunitdir], [$with_systemdsystemunitdir])
+fi
+AC_MSG_RESULT($systemdsystemunitdir)
+if test -n "$with_systemdsystemunitdir" -a "x$with_systemdsystemunitdir" != xno; then
+	SYSTEMD_SERVICE=yes
+else
+	SYSTEMD_SERVICE=no
+fi
+
+################################################################################
 dnl -- Compatibility mode
 AC_ARG_ENABLE(compat,
 	      AC_HELP_STRING([--enable-compat],
@@ -1368,6 +1385,7 @@ AC_SUBST(UDEV_LIBS)
 AC_SUBST(UDEV_PC)
 AC_SUBST(UDEV_RULES)
 AC_SUBST(UDEV_SYNC)
+AC_SUBST(SYSTEMD_SERVICE)
 AC_SUBST(WRITE_INSTALL)
 AC_SUBST(interface)
 AC_SUBST(kerneldir)
@@ -1376,6 +1394,7 @@ AC_SUBST(kernelvsn)
 AC_SUBST(tmpdir)
 AC_SUBST(udev_prefix)
 AC_SUBST(udevdir)
+AC_SUBST(systemdsystemunitdir)
 AC_SUBST(usrlibdir)
 AC_SUBST(usrsbindir)
 
@@ -1420,6 +1439,7 @@ test/Makefile
 test/api/Makefile
 tools/Makefile
 udev/Makefile
+systemd/Makefile
 unit-tests/datastruct/Makefile
 unit-tests/regex/Makefile
 unit-tests/mm/Makefile
diff --git a/make.tmpl.in b/make.tmpl.in
index 48fd617..f3749e3 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -63,6 +63,7 @@ mandir = $(datarootdir)/man
 localedir = $(DESTDIR)@LOCALEDIR@
 staticdir = $(DESTDIR)@STATICDIR@
 udevdir = $(DESTDIR)@udevdir@
+systemdsystemunitdir = $(DESTDIR)@systemdsystemunitdir@
 pkgconfigdir = $(usrlibdir)/pkgconfig
 initdir = $(DESTDIR)@sysconfdir@/rc.d/init.d
 ocf_scriptdir = $(DESTDIR)@OCFDIR@
diff --git a/systemd/Makefile.in b/systemd/Makefile.in
new file mode 100644
index 0000000..6de2775
--- /dev/null
+++ b/systemd/Makefile.in
@@ -0,0 +1,16 @@
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+top_builddir = @top_builddir@
+
+include $(top_builddir)/make.tmpl
+
+install: lvm.service
+	$(INSTALL_DATA) -D $< $(systemdsystemunitdir)/$<
diff --git a/systemd/lvm.service b/systemd/lvm.service
new file mode 100644
index 0000000..89c1038
--- /dev/null
+++ b/systemd/lvm.service
@@ -0,0 +1,15 @@
+[Unit]
+Description=LVM activation
+DefaultDependencies=no
+After=udev-settle.service
+Before=basic.target shutdown.target
+Conflicts=shutdown.target
+
+[Service]
+ExecStart=/sbin/vgchange -a y
+Type=oneshot
+TimeoutSec=0
+RemainAfterExit=yes
+
+[Install]
+WantedBy=basic.target
-- 
1.7.3.4

-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: application/pgp-signature
Size: 198 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110218/73960f96/attachment.sig>
