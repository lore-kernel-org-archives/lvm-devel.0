From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:24:56 +0000 (UTC)
Subject: master - nix: Import the modular specfile we use for nix-driven builds.
Message-ID: <20140228102456.F1888609E0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2fbc94f974c96e98d32fc426333c81c0d1a4c004
Commit:        2fbc94f974c96e98d32fc426333c81c0d1a4c004
Parent:        38ab4c31a65b6ade5ec1e49dca4ef596a9c80923
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed May 8 12:33:11 2013 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:49 2014 +0100

nix: Import the modular specfile we use for nix-driven builds.

---
 spec/build.inc    |   48 ++++++
 spec/lvm2.spec    |   13 ++
 spec/macros.inc   |   73 ++++++++
 spec/packages.inc |  476 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 spec/source.inc   |   99 +++++++++++
 5 files changed, 709 insertions(+), 0 deletions(-)

diff --git a/spec/build.inc b/spec/build.inc
new file mode 100644
index 0000000..fd455bb
--- /dev/null
+++ b/spec/build.inc
@@ -0,0 +1,48 @@
+%with udevdir %{_udevdir}
+%enableif %{enable_cmirror} cmirrord
+%enableif %{enable_udev} udev_sync
+%enableif %{enable_profiling} profiling
+%global enable_lvmetad %(if echo %{services} | grep -q lvmetad; then echo 1; else echo 0; fi)
+%enableif %{enable_lvmetad} lvmetad
+
+%build
+%configure \
+  --with-default-dm-run-dir=%{_default_dm_run_dir} \
+  --with-default-run-dir=%{_default_run_dir} \
+  --with-default-pid-dir=%{_default_pid_dir} \
+  --with-default-locking-dir=%{_default_locking_dir} \
+  --with-usrlibdir=%{_libdir} \
+  --enable-lvm1_fallback \
+  --enable-fsadm \
+  --with-pool=internal \
+  --with-user= \
+  --with-group= \
+  --with-device-uid=0 \
+  --with-device-gid=6 \
+  --with-device-mode=0660 \
+  --enable-pkgconfig \
+  --enable-applib \
+  --enable-cmdlib \
+  --enable-dmeventd \
+  %{configure_flags}
+
+make %{?_smp_mflags}
+%{?extra_build_commands}
+
+%install
+make install DESTDIR=$RPM_BUILD_ROOT
+make install_system_dirs DESTDIR=$RPM_BUILD_ROOT
+make install_initscripts DESTDIR=$RPM_BUILD_ROOT
+%if %{enable_systemd}
+make install_systemd_units DESTDIR=$RPM_BUILD_ROOT
+make install_tmpfiles_configuration DESTDIR=$RPM_BUILD_ROOT
+%endif
+
+# when building an src.rpm from freestanding specfiles
+test -e %{_sourcedir}/source.inc || cp source.inc build.inc packages.inc macros.inc %{_sourcedir}
+
+%check
+%{?check_commands}
+
+%clean
+rm -rf $RPM_BUILD_ROOT
diff --git a/spec/lvm2.spec b/spec/lvm2.spec
new file mode 100644
index 0000000..f339367
--- /dev/null
+++ b/spec/lvm2.spec
@@ -0,0 +1,13 @@
+%define import() %include %(test -e %{S:%1} && echo %{S:%1} || echo %{_sourcedir}/%1)
+
+%import source.inc
+
+# PatchN: nnn.patch goes here
+
+%prep
+%setup -q -n LVM2.%{version}
+
+%import build.inc
+%import packages.inc
+
+%changelog
diff --git a/spec/macros.inc b/spec/macros.inc
new file mode 100644
index 0000000..4041086
--- /dev/null
+++ b/spec/macros.inc
@@ -0,0 +1,73 @@
+%global _default_pid_dir /run
+%global _default_dm_run_dir /run
+%global _default_run_dir /run/lvm
+%global _default_locking_dir /run/lock/lvm
+%global _udevbasedir %{_prefix}/lib/udev
+%global _udevdir %{_udevbasedir}/rules.d
+
+%if !0%{?fedora}
+%global fedora 0
+%endif
+
+%if !0%{?rhel}
+%global rhel 0
+%endif
+
+%define enableif() \
+%global configure_flags %{?configure_flags} --%(if test %1 -gt 0; then echo enable-%2; else echo disable-%2; fi)
+
+%define with() \
+%global configure_flags %(echo -n "%{?configure_flags} " | sed -e "s,--with-%1=[^ ]*,,"; test -n "%{?2}" && echo --with-%1=%2) \
+%global with_flags %(echo -n "%{?with_flags} " | sed -e "s,%1,,"; test -n "%{?2}" && echo %1)
+
+%global services monitor
+%define service() \
+%global services %(echo -n "%{?services} " | sed -e s,%1,,; test "%2" = 1 && echo %1)
+
+%define maybe() \
+%if %(test -n "%{?2}" && echo 1 || echo 0) \
+%* \
+%endif
+
+%define have_with() %(if echo %{with_flags} | grep -q %1; then echo 1; else echo 0; fi)
+%define have_service() %(if echo %{services} | grep -q %1; then echo 1; else echo 0; fi)
+
+%define daemon_reload \
+%if %{enable_systemd} \
+/bin/systemctl daemon-reload > /dev/null 2>&1 || : \
+%endif \
+: \
+%{nil}
+
+%define enable(s:t:) \
+%if %{have_service %{-s*}} \
+%if %{enable_systemd} \
+  /bin/systemctl enable lvm2-%{-s*}.%{-t*} > /dev/null 2>&1 || : \
+%else \
+  /sbin/chkconfig --add lvm2-%{-s*} \
+%endif \
+%endif \
+: \
+%{nil}
+
+%define disable(s:t:) \
+%if %{have_service %{-s*}} \
+%if %{enable_systemd} \
+    /bin/systemctl --no-reload disable lvm2-%{-s*}.%{-t*} > /dev/null 2>&1 || : \
+    /bin/systemctl stop lvm2-%{-s*}.%{-t*} > /dev/null 2>&1 || : \
+%if %{-t*} == socket \
+        /bin/systemctl stop lvm2-%{-s*}.service > /dev/null 2>&1 || : \
+%endif \
+%else \
+    /sbin/chkconfig --del lvm2-%{-s*} \
+%endif \
+%endif \
+: \
+%{nil}
+
+%define try_restart(s:t:) \
+%if %{have_service %{-s*}} && %{enable_systemd} \
+    /bin/systemctl try-restart lvm2-%{-s*}.%{-t*} > /dev/null 2>&1 || : \
+%endif \
+    : \
+%{nil}
diff --git a/spec/packages.inc b/spec/packages.inc
new file mode 100644
index 0000000..b6f09f3
--- /dev/null
+++ b/spec/packages.inc
@@ -0,0 +1,476 @@
+### MAIN PACKAGE (lvm2)
+
+%post
+/sbin/ldconfig
+%daemon_reload
+%enable -s monitor -t service
+%enable -s lvmetad -t socket
+
+%preun
+if [ "$1" = 0 ]; then
+%disable -s monitor -t service
+%disable -s lvmetad -t socket
+fi
+
+%postun
+%daemon_reload
+
+if [ $1 -ge 1 ]; then
+%try_restart -s monitor -t service
+%try_restart -s lvmetad -t service
+fi
+
+%triggerun -- %{name} < 2.02.86-2
+%{_bindir}/systemd-sysv-convert --save lvm2-monitor >/dev/null 2>&1 || :
+/bin/systemctl --no-reload enable lvm2-monitor.service > /dev/null 2>&1 || :
+/sbin/chkconfig --del lvm2-monitor > /dev/null 2>&1 || :
+/bin/systemctl try-restart lvm2-monitor.service > /dev/null 2>&1 || :
+# files in the main package
+
+%files
+%defattr(-,root,root,-)
+%doc COPYING COPYING.LIB INSTALL README VERSION WHATS_NEW
+%doc doc/lvm_fault_handling.txt
+%{_sbindir}/fsadm
+%{_sbindir}/lvchange
+%{_sbindir}/lvconvert
+%{_sbindir}/lvcreate
+%{_sbindir}/lvdisplay
+%{_sbindir}/lvextend
+%{_sbindir}/lvm
+%{_sbindir}/lvmchange
+%{_sbindir}/lvmdiskscan
+%{_sbindir}/lvmdump
+%{_sbindir}/lvmsadc
+%{_sbindir}/lvmsar
+%{_sbindir}/lvreduce
+%{_sbindir}/lvremove
+%{_sbindir}/lvrename
+%{_sbindir}/lvresize
+%{_sbindir}/lvs
+%{_sbindir}/lvscan
+%{_sbindir}/pvchange
+%{_sbindir}/pvck
+%{_sbindir}/pvcreate
+%{_sbindir}/pvdisplay
+%{_sbindir}/pvmove
+%{_sbindir}/pvremove
+%{_sbindir}/pvresize
+%{_sbindir}/pvs
+%{_sbindir}/pvscan
+%{_sbindir}/vgcfgbackup
+%{_sbindir}/vgcfgrestore
+%{_sbindir}/vgchange
+%{_sbindir}/vgck
+%{_sbindir}/vgconvert
+%{_sbindir}/vgcreate
+%{_sbindir}/vgdisplay
+%{_sbindir}/vgexport
+%{_sbindir}/vgextend
+%{_sbindir}/vgimport
+%{_sbindir}/vgimportclone
+%{_sbindir}/vgmerge
+%{_sbindir}/vgmknodes
+%{_sbindir}/vgreduce
+%{_sbindir}/vgremove
+%{_sbindir}/vgrename
+%{_sbindir}/vgs
+%{_sbindir}/vgscan
+%{_sbindir}/vgsplit
+%{_sbindir}/lvmconf
+%{_sbindir}/blkdeactivate
+%if %{have_service lvmetad}
+ %{_sbindir}/lvmetad
+%endif
+%{_mandir}/man5/lvm.conf.5.gz
+%{_mandir}/man8/fsadm.8.gz
+%{_mandir}/man8/lvchange.8.gz
+%{_mandir}/man8/lvconvert.8.gz
+%{_mandir}/man8/lvcreate.8.gz
+%{_mandir}/man8/lvdisplay.8.gz
+%{_mandir}/man8/lvextend.8.gz
+%{_mandir}/man8/lvm.8.gz
+%{_mandir}/man8/lvmchange.8.gz
+%{_mandir}/man8/lvmconf.8.gz
+%{_mandir}/man8/lvmdiskscan.8.gz
+%{_mandir}/man8/lvmdump.8.gz
+%{_mandir}/man8/lvmsadc.8.gz
+%{_mandir}/man8/lvmsar.8.gz
+%{_mandir}/man8/lvreduce.8.gz
+%{_mandir}/man8/lvremove.8.gz
+%{_mandir}/man8/lvrename.8.gz
+%{_mandir}/man8/lvresize.8.gz
+%{_mandir}/man8/lvs.8.gz
+%{_mandir}/man8/lvscan.8.gz
+%{_mandir}/man8/pvchange.8.gz
+%{_mandir}/man8/pvck.8.gz
+%{_mandir}/man8/pvcreate.8.gz
+%{_mandir}/man8/pvdisplay.8.gz
+%{_mandir}/man8/pvmove.8.gz
+%{_mandir}/man8/pvremove.8.gz
+%{_mandir}/man8/pvresize.8.gz
+%{_mandir}/man8/pvs.8.gz
+%{_mandir}/man8/pvscan.8.gz
+%{_mandir}/man8/vgcfgbackup.8.gz
+%{_mandir}/man8/vgcfgrestore.8.gz
+%{_mandir}/man8/vgchange.8.gz
+%{_mandir}/man8/vgck.8.gz
+%{_mandir}/man8/vgconvert.8.gz
+%{_mandir}/man8/vgcreate.8.gz
+%{_mandir}/man8/vgdisplay.8.gz
+%{_mandir}/man8/vgexport.8.gz
+%{_mandir}/man8/vgextend.8.gz
+%{_mandir}/man8/vgimport.8.gz
+%{_mandir}/man8/vgimportclone.8.gz
+%{_mandir}/man8/vgmerge.8.gz
+%{_mandir}/man8/vgmknodes.8.gz
+%{_mandir}/man8/vgreduce.8.gz
+%{_mandir}/man8/vgremove.8.gz
+%{_mandir}/man8/vgrename.8.gz
+%{_mandir}/man8/vgs.8.gz
+%{_mandir}/man8/vgscan.8.gz
+%{_mandir}/man8/vgsplit.8.gz
+%{_mandir}/man8/blkdeactivate.8.gz
+%if %{enable_udev}
+ %{_udevdir}/11-dm-lvm.rules
+ %if %{have_service lvmetad}
+  %{_mandir}/man8/lvmetad.8.gz
+  %{_udevdir}/69-dm-lvm-metad.rules
+ %endif
+%endif
+%dir %{_sysconfdir}/lvm
+%ghost %{_sysconfdir}/lvm/cache/.cache
+%config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/lvm.conf
+%dir %{_sysconfdir}/lvm/backup
+%dir %{_sysconfdir}/lvm/cache
+%dir %{_sysconfdir}/lvm/archive
+%dir %{_default_locking_dir}
+%dir %{_default_run_dir}
+%if %{enable_systemd}
+ %config(noreplace) %{_prefix}/lib/tmpfiles.d/%{name}.conf
+ %{_unitdir}/lvm2-monitor.service
+ %if %{have_service lvmetad}
+  %{_unitdir}/lvm2-lvmetad.socket
+  %{_unitdir}/lvm2-lvmetad.service
+  %{_unitdir}/blk-availability.service
+ %endif
+%else
+ %{_sysconfdir}/rc.d/init.d/lvm2-monitor
+ %{_sysconfdir}/rc.d/init.d/blk-availability
+ %if %{have_service lvmetad}
+  %{_sysconfdir}/rc.d/init.d/lvm2-lvmetad
+ %endif
+%endif
+
+##############################################################################
+# Library and Development subpackages
+##############################################################################
+%package devel
+Summary: Development libraries and headers
+Group: Development/Libraries
+License: LGPLv2
+Requires: %{name} = %{version}-%{release}
+Requires: device-mapper-devel >= %{device_mapper_version}-%{release}
+Requires: device-mapper-event-devel >= %{device_mapper_version}-%{release}
+Requires: pkgconfig
+
+%description devel
+This package contains files needed to develop applications that use
+the lvm2 libraries.
+
+%files devel
+%defattr(-,root,root,-)
+%{_libdir}/liblvm2app.so
+%{_libdir}/liblvm2cmd.so
+%{_includedir}/lvm2app.h
+%{_includedir}/lvm2cmd.h
+%{_libdir}/pkgconfig/lvm2app.pc
+%{_libdir}/libdevmapper-event-lvm2.so
+
+%package libs
+Summary: Shared libraries for lvm2
+License: LGPLv2
+Group: System Environment/Libraries
+Requires: device-mapper-event >= %{device_mapper_version}-%{release}
+
+%description libs
+This package contains shared lvm2 libraries for applications.
+
+%post libs -p /sbin/ldconfig
+
+%postun libs -p /sbin/ldconfig
+
+%files libs
+%defattr(-,root,root,-)
+%attr(755,root,root) %{_libdir}/liblvm2app.so.*
+%attr(755,root,root) %{_libdir}/liblvm2cmd.so.*
+%attr(755,root,root) %{_libdir}/libdevmapper-event-lvm2.so.*
+%dir %{_libdir}/device-mapper
+%{_libdir}/device-mapper/libdevmapper-event-lvm2mirror.so
+%{_libdir}/device-mapper/libdevmapper-event-lvm2snapshot.so
+%{_libdir}/device-mapper/libdevmapper-event-lvm2raid.so
+%if %{have_with thin}
+%{_libdir}/device-mapper/libdevmapper-event-lvm2thin.so
+%{_libdir}/libdevmapper-event-lvm2thin.so
+%endif
+%{_libdir}/libdevmapper-event-lvm2mirror.so
+%{_libdir}/libdevmapper-event-lvm2snapshot.so
+%{_libdir}/libdevmapper-event-lvm2raid.so
+
+##############################################################################
+# Cluster subpackage
+##############################################################################
+%if %{have_with clvmd}
+
+%package cluster
+Summary: Cluster extensions for userland logical volume management tools
+License: GPLv2
+Group: System Environment/Base
+Requires: lvm2 >= %{version}-%{release}
+Requires(post): chkconfig
+Requires(preun): chkconfig
+Requires(preun): device-mapper >= %{device_mapper_version}
+Requires(preun): lvm2 >= 2.02
+%maybe Requires: %{req_cluster}
+
+%description cluster
+
+Extensions to LVM2 to support clusters.
+
+%post cluster
+/sbin/chkconfig --add clvmd
+
+if [ "$1" -gt "1" ] ; then
+	/usr/sbin/clvmd -S >/dev/null 2>&1 || :
+fi
+
+%preun cluster
+if [ "$1" = 0 ]; then
+	/sbin/chkconfig --del clvmd
+        # lvmconf may no longer exist if lvm2 is being removed in the same rpm run
+	if test -x /sbin/lvmconf; then /sbin/lvmconf --disable-cluster; fi
+fi
+
+%files cluster
+%defattr(-,root,root,-)
+%attr(755,root,root) /usr/sbin/clvmd
+%{_mandir}/man8/clvmd.8.gz
+%{_sysconfdir}/rc.d/init.d/clvmd
+
+%endif
+
+##############################################################################
+# Cluster mirror subpackage
+##############################################################################
+%if %{enable_cmirror}
+
+%package -n cmirror
+Summary: Daemon for device-mapper-based clustered mirrors
+Group: System Environment/Base
+Requires(post): chkconfig
+Requires(preun): chkconfig
+Requires: corosync >= %{corosync_version}
+Requires: device-mapper >= %{device_mapper_version}-%{release}
+
+%description -n cmirror
+Daemon providing device-mapper-based mirrors in a shared-storage cluster.
+
+%post -n cmirror
+/sbin/chkconfig --add cmirrord
+
+%preun -n cmirror
+if [ "$1" = 0 ]; then
+	/sbin/chkconfig --del cmirrord
+fi
+
+%files -n cmirror
+%defattr(-,root,root,-)
+%attr(755,root,root) /usr/sbin/cmirrord
+%{_mandir}/man8/cmirrord.8.gz
+%{_sysconfdir}/rc.d/init.d/cmirrord
+
+%endif
+
+##############################################################################
+# Legacy SysV init subpackage
+##############################################################################
+%if %{enable_systemd}
+
+%package sysvinit
+Summary: SysV style init script for LVM2.
+Group: System Environment/Base
+Requires: %{name} = %{version}-%{release}
+Requires: initscripts
+
+%description sysvinit
+SysV style init script for LVM2. It needs to be installed only if systemd
+is not used as the system init process.
+
+%files sysvinit
+%{_sysconfdir}/rc.d/init.d/lvm2-monitor
+%{_sysconfdir}/rc.d/init.d/blk-availability
+%if %{have_service lvmetad}
+%{_sysconfdir}/rc.d/init.d/lvm2-lvmetad
+%endif
+
+%endif
+
+##############################################################################
+# Device-mapper subpackages
+##############################################################################
+%package -n device-mapper
+Summary: Device mapper utility
+Version: %{device_mapper_version}
+Release: %{release}
+License: GPLv2
+Group: System Environment/Base
+URL: http://sources.redhat.com/dm
+Requires: device-mapper-libs = %{device_mapper_version}-%{release}
+Requires: util-linux >= 2.15
+%maybe Requires: %{req_udev}
+%if %{enable_udev}
+# We need dracut to install required udev rules if udev_sync
+# feature is turned on so we don't lose required notifications.
+Conflicts: dracut < 002-18
+%endif
+
+%description -n device-mapper
+This package contains the supporting userspace utility, dmsetup,
+for the kernel device-mapper.
+
+%files -n device-mapper
+%defattr(-,root,root,-)
+%doc COPYING COPYING.LIB WHATS_NEW_DM VERSION_DM README INSTALL
+%attr(755,root,root) %{_sbindir}/dmsetup
+%{_mandir}/man8/dmsetup.8.gz
+%if %{enable_udev}
+%doc udev/12-dm-permissions.rules
+%dir %{_udevbasedir}
+%dir %{_udevdir}
+%{_udevdir}/10-dm.rules
+%{_udevdir}/13-dm-disk.rules
+%{_udevdir}/95-dm-notify.rules
+%endif
+
+%package -n device-mapper-devel
+Summary: Development libraries and headers for device-mapper
+Version: %{device_mapper_version}
+Release: %{release}
+License: LGPLv2
+Group: Development/Libraries
+Requires: device-mapper = %{device_mapper_version}-%{release}
+Requires: pkgconfig
+
+%description -n device-mapper-devel
+This package contains files needed to develop applications that use
+the device-mapper libraries.
+
+%files -n device-mapper-devel
+%defattr(-,root,root,-)
+%{_libdir}/libdevmapper.so
+%{_includedir}/libdevmapper.h
+%{_libdir}/pkgconfig/devmapper.pc
+
+%package -n device-mapper-libs
+Summary: Device-mapper shared library
+Version: %{device_mapper_version}
+Release: %{release}
+License: LGPLv2
+Group: System Environment/Libraries
+Requires: device-mapper = %{device_mapper_version}-%{release}
+
+%description -n device-mapper-libs
+This package contains the device-mapper shared library, libdevmapper.
+
+%post -n device-mapper-libs -p /sbin/ldconfig
+
+%postun -n device-mapper-libs -p /sbin/ldconfig
+
+%files -n device-mapper-libs
+%attr(755,root,root) %{_libdir}/libdevmapper.so.*
+
+%package -n device-mapper-event
+Summary: Device-mapper event daemon
+Group: System Environment/Base
+Version: %{device_mapper_version}
+Release: %{release}
+Requires: device-mapper = %{device_mapper_version}-%{release}
+Requires: device-mapper-event-libs = %{device_mapper_version}-%{release}
+%if %{enable_systemd}
+Requires(post): systemd-units
+Requires(preun): systemd-units
+Requires(postun): systemd-units
+%endif
+
+%description -n device-mapper-event
+This package contains the dmeventd daemon for monitoring the state
+of device-mapper devices.
+
+%post -n device-mapper-event
+%if %{enable_systemd}
+/bin/systemctl daemon-reload > /dev/null 2>&1 || :
+/bin/systemctl enable dm-event.socket > /dev/null 2>&1 || :
+%endif
+
+%preun -n device-mapper-event
+%if %{enable_systemd}
+if [ "$1" = 0 ]; then
+	/bin/systemctl --no-reload disable dm-event.service dm-event.socket > /dev/null 2>&1 || :
+	/bin/systemctl stop dm-event.service dm-event.socket> /dev/null 2>&1 || :
+fi
+%endif
+
+%postun -n device-mapper-event
+%if %{enable_systemd}
+/bin/systemctl daemon-reload > /dev/null 2>&1 || :
+if [ $1 -ge 1 ]; then
+	/bin/systemctl reload dm-event.service > /dev/null 2>&1 || :
+fi
+%endif
+
+%files -n device-mapper-event
+%defattr(-,root,root,-)
+%{_sbindir}/dmeventd
+%{_mandir}/man8/dmeventd.8.gz
+%if %{enable_systemd}
+%{_unitdir}/dm-event.socket
+%{_unitdir}/dm-event.service
+%endif
+
+%package -n device-mapper-event-libs
+Summary: Device-mapper event daemon shared library
+Version: %{device_mapper_version}
+Release: %{release}
+License: LGPLv2
+Group: System Environment/Libraries
+
+%description -n device-mapper-event-libs
+This package contains the device-mapper event daemon shared library,
+libdevmapper-event.
+
+%post -n device-mapper-event-libs -p /sbin/ldconfig
+
+%postun -n device-mapper-event-libs -p /sbin/ldconfig
+
+%files -n device-mapper-event-libs
+%attr(755,root,root) %{_libdir}/libdevmapper-event.so.*
+
+%package -n device-mapper-event-devel
+Summary: Development libraries and headers for the device-mapper event daemon
+Version: %{device_mapper_version}
+Release: %{release}
+License: LGPLv2
+Group: Development/Libraries
+Requires: device-mapper-event = %{device_mapper_version}-%{release}
+Requires: pkgconfig
+
+%description -n device-mapper-event-devel
+This package contains files needed to develop applications that use
+the device-mapper event library.
+
+%files -n device-mapper-event-devel
+%defattr(-,root,root,-)
+%{_libdir}/libdevmapper-event.so
+%{_includedir}/libdevmapper-event.h
+%{_libdir}/pkgconfig/devmapper-event.pc
+
diff --git a/spec/source.inc b/spec/source.inc
new file mode 100644
index 0000000..f82ff7b
--- /dev/null
+++ b/spec/source.inc
@@ -0,0 +1,99 @@
+%import macros.inc
+
+##############################################################
+# Defaults (rawhide)... 
+
+%global enable_profiling 0
+%global enable_udev 1
+%global enable_systemd 1
+%global enable_cmirror 1
+
+%global buildreq_cluster corosync-devel >= 1.99.9-1, dlm-devel >= 3.99.1-1
+%global req_cluster corosync >= 1.99.9-1, dlm >= 3.99.2-1
+%with clvmd corosync
+
+# TODO %global req_dm_persistent device-mapper-persistent-data >= 0.1.4
+%with thin internal
+%with thin_check %{_sbindir}/thin_check
+
+%global buildreq_udev systemd-devel
+%global req_udev udev >= 181-1
+
+%service lvmetad 1
+
+##############################################################
+
+%if %{fedora} == 16 || %{rhel} == 6
+%global enable_systemd 0
+
+%global buildreq_udev libudev-devel
+%global buildreq_cluster openaislib-devel >= 1.1.1-1, clusterlib-devel >= 3.0.6-1, corosynclib-devel >= 1.2.0-1
+
+%global req_udev udev >= 158-1
+%global req_cluster openais >= 1.1.1-1, cman >= 3.0.6-1, corosync >= 1.2.0-1
+%with thin
+%with thin_check
+%endif
+
+##############################################################
+
+%if %{fedora} == 17
+%global buildreq_udev systemd-devel
+%global buildreq_cluster corosync-devel >= 1.99.9-1, dlm-devel >= 3.99.1-1
+
+%global req_udev udev >= 181-1
+%global req_dm_persistent device-mapper-persistent-data >= 0.1.4
+%global req_cluster corosync >= 1.99.9-1, dlm >= 3.99.2-1
+%endif
+
+##############################################################
+# same as FC 16 above, only with older udev
+
+%if %{rhel} == 6
+%define req_udev udev >= 147-2
+%endif
+
+##############################################################
+
+# Do not reset Release to 1 unless both lvm2 and device-mapper
+# versions are increased together.
+
+%define device_mapper_version 1.02.75
+
+Summary: Userland logical volume management tools
+Name: lvm2
+Version: 2.02.96
+Release: 4%{?dist}
+License: GPLv2
+Group: System Environment/Base
+URL: http://sources.redhat.com/lvm2
+Source0: ftp://sources.redhat.com/pub/lvm2/LVM2.%{version}.tgz
+Source91: source.inc
+Source92: build.inc
+Source93: packages.inc
+Source94: macros.inc
+
+BuildRequires: libselinux-devel >= 1.30.19-4, libsepol-devel
+BuildRequires: ncurses-devel
+BuildRequires: readline-devel
+BuildRequires: module-init-tools
+BuildRequires: pkgconfig
+
+# Expands to nothing unless at least 2 arguments are given
+%define maybe() \
+%if %(test -n "%{?2}" && echo 1 || echo 0) \
+%* \
+%endif
+%define ifwith() \
+%if %(if echo %{with_flags} | grep -q %1; then echo 1; else echo 0; fi)
+
+%maybe BuildRequires: %{?buildreq_udev}
+%maybe BuildRequires: %{?buildreq_cluster}
+
+%description
+LVM2 includes all of the support for handling read/write operations on
+physical volumes (hard disks, RAID-Systems, magneto optical, etc.,
+multiple devices (MD), see mdadd(8) or even loop devices, see
+losetup(8)), creating volume groups (kind of virtual disks) from one
+or more physical volumes and creating one or more logical volumes
+(kind of logical partitions) in volume groups.


