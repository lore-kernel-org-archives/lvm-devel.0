From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Jun 2018 18:49:26 -0400
Subject: master - rpm: drop no longer present clvmd, lvm2app
Message-ID: <201806142249.w5EMnQTS023473@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=27c647d6ce707326237771d3b046b6049161fb5a
Commit:        27c647d6ce707326237771d3b046b6049161fb5a
Parent:        2a7f2a3a244dd02cacb947b19f7400b53dd71ca4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 15 00:47:35 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 15 00:47:35 2018 +0200

rpm: drop no longer present clvmd, lvm2app

---
 spec/packages.inc |  102 -----------------------------------------------------
 spec/source.inc   |    1 -
 2 files changed, 0 insertions(+), 103 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index cdcc197..bf2432a 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -229,11 +229,8 @@ the lvm2 libraries.
 
 %files devel
 %defattr(-,root,root,-)
-%{_libdir}/liblvm2app.so
 %{_libdir}/liblvm2cmd.so
-%{_includedir}/lvm2app.h
 %{_includedir}/lvm2cmd.h
-%{_libdir}/pkgconfig/lvm2app.pc
 %{_libdir}/libdevmapper-event-lvm2.so
 
 %package libs
@@ -251,7 +248,6 @@ This package contains shared lvm2 libraries for applications.
 
 %files libs
 %defattr(-,root,root,-)
-%attr(755,root,root) %{_libdir}/liblvm2app.so.*
 %attr(755,root,root) %{_libdir}/liblvm2cmd.so.*
 %attr(755,root,root) %{_libdir}/libdevmapper-event-lvm2.so.*
 %dir %{_libdir}/device-mapper
@@ -291,10 +287,8 @@ LVM commands use lvmlockd to coordinate access to shared storage.
 %post lockd
 %daemon_reload
 %enable -s lvmlockd -t service
-%enable -s lvmlocking -t service
 
 %preun lockd
-%disable -s lvmlocking -t service
 %disable -s lvmlockd -t service
 
 %postun lockd
@@ -309,66 +303,6 @@ fi
 %{_mandir}/man8/lvmlockctl.8.gz
 %dir %{_default_locking_dir}
 %{_unitdir}/lvm2-lvmlockd.service
-%{_unitdir}/lvm2-lvmlocking.service
-%endif
-
-##############################################################################
-# Cluster subpackage
-##############################################################################
-%if %{have_with clvmd}
-
-%package cluster
-Summary: Cluster extensions for userland logical volume management tools
-License: GPLv2
-Group: System Environment/Base
-Requires: lvm2 >= %{version}-%{release}
-Requires(post): chkconfig
-Requires(preun): chkconfig
-Requires(preun): device-mapper >= %{device_mapper_version}
-Requires(preun): lvm2 >= 2.02
-%maybe Requires: %{req_cluster}
-
-%description cluster
-
-Extensions to LVM2 to support clusters.
-
-%post cluster
-%daemon_reload
-%enable -s clvmd -t service
-%if %{have_service clvmd}
-if [ $1 = 2 ]; then
-	if [ -e %{_default_pid_dir}/clvmd.pid ]; then
-		%{_sbindir}/clvmd -S >/dev/null 2>&1 || :
-	fi
-fi
-%endif
-
-%preun cluster
-%disable -s clvmd -t service
-%if %{have_service clvmd}
-if [ $1 = 0 ]; then
-	# lvmconf may no longer exist if lvm2 is being removed in the same rpm run
-	if test -x /sbin/lvmconf; then /sbin/lvmconf --disable-cluster; fi
-fi
-%endif
-
-%postun cluster
-if [ $1 = 0 ]; then
-%daemon_reload
-fi
-
-%files cluster
-%defattr(-,root,root,-)
-%attr(755,root,root) /usr/sbin/clvmd
-%{_mandir}/man8/clvmd.8.gz
-%if %{enable_systemd}
-  %{_unitdir}/lvm2-clvmd.service
-  %{_unitdir}/lvm2-cluster-activation.service
-  %{_unitdir}/../lvm2-cluster-activation
-%else
-  %{_sysconfdir}/rc.d/init.d/clvmd
-%endif
-
 %endif
 
 ##############################################################################
@@ -413,42 +347,6 @@ fi
 %endif
 
 ##############################################################################
-# Python bindings
-##############################################################################
-%if %{enable_python}
-%package python-libs
-Summary: Python module to access LVM
-License: LGPLv2
-Group: Development/Libraries
-Provides: python-lvm = %{version}-%{release}
-Requires: %{name}-libs = %{version}-%{release}
-
-%description python-libs
-Python module to allow the creation and use of LVM
-logical volumes, physical volumes, and volume groups.
-
-%files python-libs
-%{python_sitearch}/*
-%endif
-
-%if %{enable_python3}
-%package python3-libs
-Summary: Python 3 module to access LVM
-License: LGPLv2
-Group: Development/Libraries
-Provides: python3-lvm = %{version}-%{release}
-Requires: %{name}-libs = %{version}-%{release}
-
-%description python3-libs
-Python 3 module to allow the creation and use of LVM
-logical volumes, physical volumes, and volume groups.
-
-%files python3-libs
-%{python3_sitearch}/*.so
-%{python3_sitearch}/*.egg-info
-%endif
-
-##############################################################################
 # LVM D-Bus daemon
 ##############################################################################
 %if %{enable_dbusd}
diff --git a/spec/source.inc b/spec/source.inc
index fb7ccf5..6a485ef 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -30,7 +30,6 @@
 # enable service only if you know what you are doing
 #
 %if %{enable_cmirror}
-#service clvmd 1
 #service cmirrord 1
 %endif
 


