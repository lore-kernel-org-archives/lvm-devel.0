From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Thu, 18 Feb 2016 19:47:16 +0000 (UTC)
Subject: master - spec: Update python bindings and dbus-service
Message-ID: <20160218194716.1505460AA5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=04ab1fa572bbc6751463b137576bc733ec27b2ca
Commit:        04ab1fa572bbc6751463b137576bc733ec27b2ca
Parent:        a89ddda1a292402a2cf2422d09e58dba46079163
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Feb 18 14:34:17 2016 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Feb 18 20:46:03 2016 +0100

spec: Update python bindings and dbus-service

The workaround for python3 is no longer needed.
---
 spec/build.inc    |   12 ++----------
 spec/packages.inc |   44 +++++++++++++++++++++++++++++++++++++++++++-
 spec/source.inc   |   17 +++++++++++++++++
 3 files changed, 62 insertions(+), 11 deletions(-)

diff --git a/spec/build.inc b/spec/build.inc
index 2bb285d..3ba7840 100644
--- a/spec/build.inc
+++ b/spec/build.inc
@@ -31,20 +31,12 @@
 %enableif %{enable_lockd_sanlock} lockd-sanlock
 %endif
 %enableif %{enable_python} python2-bindings
+%enableif %{enable_python3} python3-bindings
 %enableif %{enable_python} applib
+%enableif %{enable_dbusd} dbus-service
 
 %build
 
-%if %{enable_python3}
-rm -rf %{py3dir}
-cp -a . %{py3dir}
-pushd %{py3dir}
-%configure %{configure_flags} --disable-python2-bindings --enable-python3-bindings PYTHON=/usr/bin/python3 PYTHON_CONFIG=/usr/bin/python3-config
-
-make %{?_smp_mflags}
-popd
-%endif
-
 %configure %{configure_flags}
 
 make %{?_smp_mflags}
diff --git a/spec/packages.inc b/spec/packages.inc
index 6c3dfde..bfc6703 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -442,7 +442,49 @@ Python 3 module to allow the creation and use of LVM
 logical volumes, physical volumes, and volume groups.
 
 %files python3-libs
-%{python3_sitearch}/*
+%{python3_sitearch}/*.so
+%{python3_sitearch}/*.egg-info
+%endif
+
+##############################################################################
+# LVM D-Bus daemon
+##############################################################################
+%if %{enable_dbusd}
+%package dbusd
+Summary: LVM2 D-Bus daemon
+License: GPLv2
+Group: System Environment/Base
+Requires: lvm2 >= %{version}-%{release}
+Requires: dbus
+Requires: python3-dbus
+Requires: python3-pyudev
+Requires(post): systemd-units >= %{systemd_version}
+Requires(preun): systemd-units >= %{systemd_version}
+Requires(postun): systemd-units >= %{systemd_version}
+
+%description dbusd
+
+Daemon for access to LVM2 functionality through a D-Bus interface.
+
+%post dbusd
+%systemd_post lvm2-lvmdbusd.service
+
+%preun dbusd
+%systemd_preun lvm2-lvmdbusd.service
+
+%postun dbusd
+%systemd_postun lvm2-lvmdbusd.service
+
+%files dbusd
+%defattr(555,root,root,-)
+%{_sbindir}/lvmdbusd
+%defattr(444,root,root,-)
+%{_sysconfdir}/dbus-1/system.d/com.redhat.lvmdbus1.conf
+%{_datadir}/dbus-1/system-services/com.redhat.lvmdbus1.service
+%{_mandir}/man8/lvmdbusd.8.gz
+%{_unitdir}/lvm2-lvmdbusd.service
+%{python3_sitelib}/lvmdbusd/*
+
 %endif
 
 ##############################################################################
diff --git a/spec/source.inc b/spec/source.inc
index 07859ba..97f29f1 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -8,6 +8,7 @@
 %global enable_python 1
 # Off by default - <= does not work well with or:
 %global enable_python3 0
+%global enable_dbusd 0
 %global enable_udev 1
 %global enable_systemd 1
 %global enable_cmirror 1
@@ -87,6 +88,22 @@
 
 ##############################################################
 
+%if %{rhel} >= 8 || %{fedora} >= 23
+  %if %{enable_python3}
+    %global enable_dbusd 1
+  %else
+    # dbusd requires python3
+    false
+  %endif
+%endif
+
+%if %{enable_dbusd}
+  %global buildreq_python3_dbus python3-dbus
+  %global buildreq_python3_pyudev python3-pyudev
+%endif
+
+##############################################################
+
 %if %{fedora} == 16 || %{rhel} == 6
 %global enable_systemd 0
 


