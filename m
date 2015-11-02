From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Mon,  2 Nov 2015 13:41:39 +0000 (UTC)
Subject: master - spec: Add python bindings
Message-ID: <20151102134139.4F18861056@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=89574055f7a0d2e7dd10a781f5fbde4eeae1f637
Commit:        89574055f7a0d2e7dd10a781f5fbde4eeae1f637
Parent:        7831a650914f35c97f9deab6b871970b303a8948
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Nov 2 11:33:13 2015 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Nov 2 12:42:32 2015 +0100

spec: Add python bindings

---
 spec/build.inc    |   58 +++++++++++++++++++++++++++++---------------
 spec/packages.inc |   69 +++++++++++++++++++++++++++++++++++++++++-----------
 spec/source.inc   |   25 +++++++++++++++++++
 3 files changed, 117 insertions(+), 35 deletions(-)

diff --git a/spec/build.inc b/spec/build.inc
index 7bab437..bc57436 100644
--- a/spec/build.inc
+++ b/spec/build.inc
@@ -1,3 +1,22 @@
+%with default-dm-run-dir %{_default_dm_run_dir}
+%with default-run-dir %{_default_run_dir}
+%with default-pid-dir %{_default_pid_dir}
+%with default-locking-dir %{_default_locking_dir}
+%with usrlibdir %{_libdir}
+%enableif 1 lvm1_fallback
+%enableif 1 fsadm
+%with pool internal
+%with user
+%with group
+%with device-uid 0
+%with device-gid 6
+%with device-mode 0660
+%enableif 1 pkgconfig
+%enableif 1 applib
+%enableif 1 cmdlib
+%enableif 1 dmeventd
+%enableif 1 write_install
+
 %with udevdir %{_udevdir}
 %enableif %{enable_cmirror} cmirrord
 %enableif %{enable_udev} udev_sync
@@ -11,28 +30,22 @@
 %enableif %{enable_lockd_dlm} lockd-dlm
 %enableif %{enable_lockd_sanlock} lockd-sanlock
 %endif
+%enableif %{enable_python} python-bindings
+%enableif %{enable_python} applib
 
 %build
-%configure \
-  --with-default-dm-run-dir=%{_default_dm_run_dir} \
-  --with-default-run-dir=%{_default_run_dir} \
-  --with-default-pid-dir=%{_default_pid_dir} \
-  --with-default-locking-dir=%{_default_locking_dir} \
-  --with-usrlibdir=%{_libdir} \
-  --enable-lvm1_fallback \
-  --enable-fsadm \
-  --with-pool=internal \
-  --with-user= \
-  --with-group= \
-  --with-device-uid=0 \
-  --with-device-gid=6 \
-  --with-device-mode=0660 \
-  --enable-pkgconfig \
-  --enable-applib \
-  --enable-cmdlib \
-  --enable-dmeventd \
-  --enable-write_install \
-  %{configure_flags}
+
+%if %{enable_python3}
+rm -rf %{py3dir}
+cp -a . %{py3dir}
+pushd %{py3dir}
+%configure %{configure_flags} PYTHON=/usr/bin/python3 PYTHON_CONFIG=/usr/bin/python3-config
+
+make %{?_smp_mflags}
+popd
+%endif
+
+%configure %{configure_flags}
 
 make %{?_smp_mflags}
 %{?extra_build_commands}
@@ -50,6 +63,11 @@ make install_initscripts DESTDIR=$RPM_BUILD_ROOT
 %if %{enable_testsuite}
 make -C test install DESTDIR=$RPM_BUILD_ROOT
 %endif
+%if %{enable_python3}
+pushd %{py3dir}
+make -C python install DESTDIR=$RPM_BUILD_ROOT
+popd
+%endif
 
 # when building an src.rpm from freestanding specfiles
 test -e %{_sourcedir}/source.inc || cp source.inc build.inc packages.inc macros.inc %{_sourcedir}
diff --git a/spec/packages.inc b/spec/packages.inc
index e0a6010..6c3dfde 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -411,6 +411,60 @@ fi
 %endif
 
 ##############################################################################
+# Python bindings
+##############################################################################
+%if %{enable_python}
+%package python-libs
+Summary: Python module to access LVM
+License: LGPLv2
+Group: Development/Libraries
+Provides: python-lvm = %{version}-%{release}
+Requires: %{name}-libs = %{version}-%{release}
+
+%description python-libs
+Python module to allow the creation and use of LVM
+logical volumes, physical volumes, and volume groups.
+
+%files python-libs
+%{python_sitearch}/*
+%endif
+
+%if %{enable_python3}
+%package python3-libs
+Summary: Python 3 module to access LVM
+License: LGPLv2
+Group: Development/Libraries
+Provides: python3-lvm = %{version}-%{release}
+Requires: %{name}-libs = %{version}-%{release}
+
+%description python3-libs
+Python 3 module to allow the creation and use of LVM
+logical volumes, physical volumes, and volume groups.
+
+%files python3-libs
+%{python3_sitearch}/*
+%endif
+
+##############################################################################
+# Testsuite subpackage
+##############################################################################
+%if %{enable_testsuite}
+%package testsuite
+Summary: LVM2 Testsuite
+License: LGPLv2
+Group: Development
+
+%description testsuite
+An extensive functional testsuite for LVM2.
+
+%files testsuite
+%defattr(-,root,root,-)
+%{_datadir}/lvm2-testsuite/
+%{_libexecdir}/lvm2-testsuite/
+%{_bindir}/lvm2-testsuite
+%endif
+
+##############################################################################
 # Device-mapper subpackages
 ##############################################################################
 %package -n device-mapper
@@ -571,18 +625,3 @@ the device-mapper event library.
 %{_includedir}/libdevmapper-event.h
 %{_libdir}/pkgconfig/devmapper-event.pc
 
-%if %{enable_testsuite}
-%package testsuite
-Summary: LVM2 Testsuite
-License: LGPLv2
-Group: Development
-
-%description testsuite
-An extensive functional testsuite for LVM2.
-
-%files testsuite
-%defattr(-,root,root,-)
-%{_datadir}/lvm2-testsuite/
-%{_libexecdir}/lvm2-testsuite/
-%{_bindir}/lvm2-testsuite
-%endif
diff --git a/spec/source.inc b/spec/source.inc
index 2681375..07859ba 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -5,6 +5,9 @@
 
 %global enable_profiling 0
 %global enable_testsuite 1
+%global enable_python 1
+# Off by default - <= does not work well with or:
+%global enable_python3 0
 %global enable_udev 1
 %global enable_systemd 1
 %global enable_cmirror 1
@@ -65,6 +68,25 @@
 
 ##############################################################
 
+%if %{rhel} == 5
+%global enable_python 0
+%endif
+
+%if %{rhel} >= 8 || %{fedora} >= 20
+%global enable_python3 1
+%endif
+
+%if %{enable_python}
+  %global buildreq_python2_devel python2-devel
+  %global buildreq_python_setuptools python-setuptools
+%endif
+%if %{enable_python3}
+  %global buildreq_python3_devel python3-devel
+  %global buildreq_python_setuptools python-setuptools
+%endif
+
+##############################################################
+
 %if %{fedora} == 16 || %{rhel} == 6
 %global enable_systemd 0
 
@@ -143,6 +165,9 @@ BuildRequires: pkgconfig
 %maybe BuildRequires: %{?buildreq_cluster}
 %maybe BuildRequires: %{?buildreq_lockd_dlm}
 %maybe BuildRequires: %{?buildreq_lockd_sanlock}
+%maybe BuildRequires: %{?buildreq_python2_devel}
+%maybe BuildRequires: %{?buildreq_python3_devel}
+%maybe BuildRequires: %{?buildreq_python_setuptools}
 
 %description
 LVM2 includes all of the support for handling read/write operations on


