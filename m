From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 May 2015 11:20:38 +0000 (UTC)
Subject: master - spec: packaging polld
Message-ID: <20150513112038.2F25F60067@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1b43d633688c5bc30cef8bc82f5db6a4fa1abeb6
Commit:        1b43d633688c5bc30cef8bc82f5db6a4fa1abeb6
Parent:        d5cef7413fb63f42eadb9b1897194f5c2f07ef30
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 13 13:14:54 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 13 13:18:59 2015 +0200

spec: packaging polld

Package lvmpolld

Drop legacy SysV init subpackage.
---
 spec/build.inc    |    5 ++++-
 spec/packages.inc |   40 ++++++++++++++--------------------------
 spec/source.inc   |    2 ++
 3 files changed, 20 insertions(+), 27 deletions(-)

diff --git a/spec/build.inc b/spec/build.inc
index 30c6402..3979073 100644
--- a/spec/build.inc
+++ b/spec/build.inc
@@ -4,6 +4,8 @@
 %enableif %{enable_profiling} profiling
 %global enable_lvmetad %(if echo %{services} | grep -q lvmetad; then echo 1; else echo 0; fi)
 %enableif %{enable_lvmetad} lvmetad
+%global enable_lvmpolld %(if echo %{services} | grep -q lvmpolld; then echo 1; else echo 0; fi)
+%enableif %{enable_lvmpolld} lvmpolld
 
 %build
 %configure \
@@ -33,10 +35,11 @@ make %{?_smp_mflags}
 %install
 make install DESTDIR=$RPM_BUILD_ROOT
 make install_system_dirs DESTDIR=$RPM_BUILD_ROOT
-make install_initscripts DESTDIR=$RPM_BUILD_ROOT
 %if %{enable_systemd}
 make install_systemd_units DESTDIR=$RPM_BUILD_ROOT
 make install_tmpfiles_configuration DESTDIR=$RPM_BUILD_ROOT
+%else
+make install_initscripts DESTDIR=$RPM_BUILD_ROOT
 %endif
 %if %{enable_testsuite}
 make -C test install DESTDIR=$RPM_BUILD_ROOT
diff --git a/spec/packages.inc b/spec/packages.inc
index 109abd2..0aaae1d 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -83,6 +83,9 @@ fi
 %if %{have_service lvmetad}
  %{_sbindir}/lvmetad
 %endif
+%if %{have_service lvmpolld}
+ %{_sbindir}/lvmpolld
+%endif
 %if %{have_with cache}
   %{_mandir}/man7/lvmcache.7.gz
 %endif
@@ -149,6 +152,9 @@ fi
   %{_udevdir}/69-dm-lvm-metad.rules
  %endif
 %endif
+%if %{have_service lvmetad}
+  %{_mandir}/man8/lvmpolld.8.gz
+%endif
 %dir %{_sysconfdir}/lvm
 %ghost %{_sysconfdir}/lvm/cache/.cache
 %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/lvm.conf
@@ -171,6 +177,10 @@ fi
   %{_unitdir}/lvm2-pvscan at .service
   %{_unitdir}/blk-availability.service
  %endif
+ %if %{have_service lvmpolld}
+  %{_unitdir}/lvm2-lvmpolld.service
+  %{_unitdir}/lvm2-lvmpolld.socket
+ %endif
 %else
  %{_sysconfdir}/rc.d/init.d/lvm2-monitor
  %{_sysconfdir}/rc.d/init.d/blk-availability
@@ -272,11 +282,12 @@ fi
 %defattr(-,root,root,-)
 %attr(755,root,root) /usr/sbin/clvmd
 %{_mandir}/man8/clvmd.8.gz
-%{_sysconfdir}/rc.d/init.d/clvmd
 %if %{enable_systemd}
   %{_unitdir}/lvm2-clvmd.service
   %{_unitdir}/lvm2-cluster-activation.service
   %{_unitdir}/../lvm2-cluster-activation
+%else
+  %{_sysconfdir}/rc.d/init.d/clvmd
 %endif
 
 %endif
@@ -309,33 +320,10 @@ fi
 %defattr(-,root,root,-)
 %attr(755,root,root) /usr/sbin/cmirrord
 %{_mandir}/man8/cmirrord.8.gz
-%{_sysconfdir}/rc.d/init.d/cmirrord
 %if %{enable_systemd}
   %{_unitdir}/lvm2-cmirrord.service
-%endif
-
-%endif
-
-##############################################################################
-# Legacy SysV init subpackage
-##############################################################################
-%if %{enable_systemd}
-
-%package sysvinit
-Summary: SysV style init script for LVM2.
-Group: System Environment/Base
-Requires: %{name} = %{version}-%{release}
-Requires: initscripts
-
-%description sysvinit
-SysV style init script for LVM2. It needs to be installed only if systemd
-is not used as the system init process.
-
-%files sysvinit
-%{_sysconfdir}/rc.d/init.d/lvm2-monitor
-%{_sysconfdir}/rc.d/init.d/blk-availability
-%if %{have_service lvmetad}
-%{_sysconfdir}/rc.d/init.d/lvm2-lvmetad
+%else
+  %{_sysconfdir}/rc.d/init.d/cmirrord
 %endif
 
 %endif
diff --git a/spec/source.inc b/spec/source.inc
index 36cb30f..a11f4b7 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -25,6 +25,8 @@
 
 %service lvmetad 1
 
+%service lvmpolld 1
+
 ##############################################################
 
 %if %{fedora} == 16 || %{rhel} == 6


