From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 10 Sep 2015 15:30:08 +0000 (UTC)
Subject: master - spec: upgrade
Message-ID: <20150910153008.68A0460AA1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0889cff5d5430cc398586285be5cccd88b4ed18f
Commit:        0889cff5d5430cc398586285be5cccd88b4ed18f
Parent:        9b8c876293b883f6c84d349d04e20a77facb69d1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 9 15:59:32 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 10 17:28:47 2015 +0200

spec: upgrade

Upgrade spec rules to be in touch with recent code.
Provide services and proper postin/preun/postun scriplets.
---
 spec/build.inc    |    1 +
 spec/macros.inc   |   32 ++++++++----
 spec/packages.inc |  144 +++++++++++++++++++++++++++++++++--------------------
 spec/source.inc   |   24 +++++++--
 4 files changed, 131 insertions(+), 70 deletions(-)

diff --git a/spec/build.inc b/spec/build.inc
index 94d5e06..7bab437 100644
--- a/spec/build.inc
+++ b/spec/build.inc
@@ -42,6 +42,7 @@ make install DESTDIR=$RPM_BUILD_ROOT
 make install_system_dirs DESTDIR=$RPM_BUILD_ROOT
 %if %{enable_systemd}
 make install_systemd_units DESTDIR=$RPM_BUILD_ROOT
+make install_systemd_generators DESTDIR=$RPM_BUILD_ROOT
 make install_tmpfiles_configuration DESTDIR=$RPM_BUILD_ROOT
 %else
 make install_initscripts DESTDIR=$RPM_BUILD_ROOT
diff --git a/spec/macros.inc b/spec/macros.inc
index 7b841dd..4c4e66b 100644
--- a/spec/macros.inc
+++ b/spec/macros.inc
@@ -4,6 +4,7 @@
 %global _default_locking_dir /run/lock/lvm
 %global _udevbasedir %{_prefix}/lib/udev
 %global _udevdir %{_udevbasedir}/rules.d
+%global _tmpfilesdir %{_prefix}/lib/tmpfiles.d
 
 %if !0%{?fedora}
 %global fedora 0
@@ -34,7 +35,7 @@
 
 %define daemon_reload \
 %if %{enable_systemd} \
-/bin/systemctl daemon-reload > /dev/null 2>&1 || : \
+systemctl daemon-reload > /dev/null 2>&1 || : \
 %endif \
 : \
 %{nil}
@@ -42,9 +43,11 @@
 %define enable(s:t:) \
 %if %{have_service %{-s*}} \
 %if %{enable_systemd} \
-  /bin/systemctl enable lvm2-%{-s*}.%{-t*} > /dev/null 2>&1 || : \
+if [ $1 = 1 ]; then \
+	systemctl preset lvm2-%{-s*}.%{-t*} > /dev/null 2>&1 || : \
+fi \
 %else \
-  /sbin/chkconfig --add lvm2-%{-s*} \
+/sbin/chkconfig --add lvm2-%{-s*} \
 %endif \
 %endif \
 : \
@@ -53,13 +56,18 @@
 %define disable(s:t:) \
 %if %{have_service %{-s*}} \
 %if %{enable_systemd} \
-    /bin/systemctl --no-reload disable lvm2-%{-s*}.%{-t*} > /dev/null 2>&1 || : \
-    /bin/systemctl stop lvm2-%{-s*}.%{-t*} > /dev/null 2>&1 || : \
-%if %{-t*} == socket \
-        /bin/systemctl stop lvm2-%{-s*}.service > /dev/null 2>&1 || : \
-%endif \
+if [ $1 = 0 ]; then \
+	systemctl --no-reload disable lvm2-%{-s*}.%{-t*} > /dev/null 2>&1 || : \
+	%if %{-t*} == socket \
+	systemctl --no-reload disable lvm2-%{-s*}.service > /dev/null 2>&1 || : \
+	%endif \
+	systemctl stop lvm2-%{-s*}.%{-t*} > /dev/null 2>&1 || : \
+	%if %{-t*} == socket \
+	systemctl stop lvm2-%{-s*}.service > /dev/null 2>&1 || : \
+	%endif \
+fi \
 %else \
-    /sbin/chkconfig --del lvm2-%{-s*} \
+/sbin/chkconfig --del lvm2-%{-s*} \
 %endif \
 %endif \
 : \
@@ -67,7 +75,9 @@
 
 %define try_restart(s:t:) \
 %if %{have_service %{-s*}} && %{enable_systemd} \
-    /bin/systemctl try-restart lvm2-%{-s*}.%{-t*} > /dev/null 2>&1 || : \
+if [ $1 = 1 ]; then \
+	systemctl try-restart lvm2-%{-s*}.%{-t*} > /dev/null 2>&1 || : \
+fi \
 %endif \
-    : \
+: \
 %{nil}
diff --git a/spec/packages.inc b/spec/packages.inc
index 69643ef..e0a6010 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -1,23 +1,34 @@
 ### MAIN PACKAGE (lvm2)
 
 %post
-/sbin/ldconfig
 %daemon_reload
 %enable -s monitor -t service
+%if %{have_service lvmetad}
 %enable -s lvmetad -t socket
+%endif
+%if %{have_service lvmpolld}
+%enable -s lvmpolld -t socket
+%endif
 
 %preun
-if [ "$1" = 0 ]; then
-%disable -s monitor -t service
+%if %{have_service lvmpolld}
+%disable -s lvmpolld -t socket
+%endif
+%if %{have_service lvmetad}
 %disable -s lvmetad -t socket
-fi
+%endif
+%disable -s monitor -t service
 
 %postun
-%daemon_reload
-
-if [ $1 -ge 1 ]; then
 %try_restart -s monitor -t service
+%if %{have_service lvmetad}
 %try_restart -s lvmetad -t service
+%endif
+%if %{have_service lvmpolld}
+%try_restart -s lvmpolld -t service
+%endif
+if [ $1 = 0 ]; then
+%daemon_reload
 fi
 
 %triggerun -- %{name} < 2.02.86-2
@@ -31,6 +42,7 @@ fi
 %defattr(-,root,root,-)
 %doc COPYING COPYING.LIB INSTALL README VERSION WHATS_NEW
 %doc doc/lvm_fault_handling.txt
+%{_sbindir}/blkdeactivate
 %{_sbindir}/fsadm
 %{_sbindir}/lvchange
 %{_sbindir}/lvconvert
@@ -39,6 +51,8 @@ fi
 %{_sbindir}/lvextend
 %{_sbindir}/lvm
 %{_sbindir}/lvmchange
+%{_sbindir}/lvmconf
+%{_sbindir}/lvmconfig
 %{_sbindir}/lvmdiskscan
 %{_sbindir}/lvmdump
 %{_sbindir}/lvmsadc
@@ -77,32 +91,28 @@ fi
 %{_sbindir}/vgs
 %{_sbindir}/vgscan
 %{_sbindir}/vgsplit
-%{_sbindir}/lvmconfig
-%{_sbindir}/lvmconf
-%{_sbindir}/blkdeactivate
 %if %{have_service lvmetad}
  %{_sbindir}/lvmetad
 %endif
 %if %{have_service lvmpolld}
  %{_sbindir}/lvmpolld
 %endif
-%if %{have_with cache}
-  %{_mandir}/man7/lvmcache.7.gz
-%endif
-%if %{have_with thin}
-  %{_mandir}/man7/lvmthin.7.gz
-%endif
-%{_mandir}/man7/lvmsystemid.7.gz
 %{_mandir}/man5/lvm.conf.5.gz
+%{_mandir}/man7/lvmsystemid.7.gz
+%{_mandir}/man8/blkdeactivate.8.gz
 %{_mandir}/man8/fsadm.8.gz
 %{_mandir}/man8/lvchange.8.gz
 %{_mandir}/man8/lvconvert.8.gz
 %{_mandir}/man8/lvcreate.8.gz
 %{_mandir}/man8/lvdisplay.8.gz
 %{_mandir}/man8/lvextend.8.gz
+%{_mandir}/man8/lvm-config.8.gz
+%{_mandir}/man8/lvm-dumpconfig.8.gz
 %{_mandir}/man8/lvm.8.gz
+%{_mandir}/man8/lvm2-activation-generator.8.gz
 %{_mandir}/man8/lvmchange.8.gz
 %{_mandir}/man8/lvmconf.8.gz
+%{_mandir}/man8/lvmconfig.8.gz
 %{_mandir}/man8/lvmdiskscan.8.gz
 %{_mandir}/man8/lvmdump.8.gz
 %{_mandir}/man8/lvmsadc.8.gz
@@ -141,10 +151,16 @@ fi
 %{_mandir}/man8/vgs.8.gz
 %{_mandir}/man8/vgscan.8.gz
 %{_mandir}/man8/vgsplit.8.gz
-%{_mandir}/man8/blkdeactivate.8.gz
-%{_mandir}/man8/lvm-dumpconfig.8.gz
-%{_mandir}/man8/lvm-config.8.gz
-%{_mandir}/man8/lvmconfig.8.gz
+%if %{have_with cache}
+  %{_mandir}/man7/lvmcache.7.gz
+%endif
+%if %{have_with thin}
+  %{_mandir}/man7/lvmthin.7.gz
+%endif
+%if %{have_service lvmpolld}
+  %{_mandir}/man8/lvmpolld.8.gz
+  %{_mandir}/man8/lvm-lvpoll.8.gz
+%endif
 %if %{enable_udev}
  %{_udevdir}/11-dm-lvm.rules
  %if %{have_service lvmetad}
@@ -152,14 +168,11 @@ fi
   %{_udevdir}/69-dm-lvm-metad.rules
  %endif
 %endif
-%if %{have_service lvmpolld}
-  %{_mandir}/man8/lvmpolld.8.gz
-  %{_mandir}/man8/lvm-lvpoll.8.gz
-%endif
 %dir %{_sysconfdir}/lvm
 %ghost %{_sysconfdir}/lvm/cache/.cache
-%config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/lvm.conf
-%config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/lvmlocal.conf
+%attr(644, -, -) %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/lvm.conf
+%attr(644, -, -) %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/lvmlocal.conf
+%dir %{_sysconfdir}/lvm/profile
 %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/command_profile_template.profile
 %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/metadata_profile_template.profile
 %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/thin-generic.profile
@@ -169,23 +182,25 @@ fi
 %dir %{_sysconfdir}/lvm/backup
 %dir %{_sysconfdir}/lvm/cache
 %dir %{_sysconfdir}/lvm/archive
-%dir %{_default_run_dir}
+%ghost %dir %{_default_locking_dir}
+%ghost %dir %{_default_run_dir}
 %if %{enable_systemd}
- %config(noreplace) %{_prefix}/lib/tmpfiles.d/%{name}.conf
+ %{_tmpfilesdir}/%{name}.conf
+ %{_unitdir}/blk-availability.service
  %{_unitdir}/lvm2-monitor.service
+ %attr(555, -, -) %{_prefix}/lib/systemd/system-generators/lvm2-activation-generator
  %if %{have_service lvmetad}
   %{_unitdir}/lvm2-lvmetad.socket
   %{_unitdir}/lvm2-lvmetad.service
   %{_unitdir}/lvm2-pvscan@.service
-  %{_unitdir}/blk-availability.service
  %endif
  %if %{have_service lvmpolld}
   %{_unitdir}/lvm2-lvmpolld.service
   %{_unitdir}/lvm2-lvmpolld.socket
  %endif
 %else
- %{_sysconfdir}/rc.d/init.d/lvm2-monitor
  %{_sysconfdir}/rc.d/init.d/blk-availability
+ %{_sysconfdir}/rc.d/init.d/lvm2-monitor
  %if %{have_service lvmetad}
   %{_sysconfdir}/rc.d/init.d/lvm2-lvmetad
  %endif
@@ -272,13 +287,18 @@ Requires(postun): systemd-units
 LVM commands use lvmlockd to coordinate access to shared storage.
 
 %post lockd
-%systemd_post lvm2-lvmlockd.service lvm2-lvmlocking.service
+%daemon_reload
+%enable -s lvmlockd -t service
+%enable -s lvmlocking -t service
 
 %preun lockd
-%systemd_preun lvm2-lvmlockd.service lvm2-lvmlocking.service
+%disable -s lvmlocking -t service
+%disable -s lvmlockd -t service
 
 %postun lockd
-%systemd_postun lvm2-lvmlockd.service lvm2-lvmlocking.service
+if [ $1 = 0 ]; then
+%daemon_reload
+fi
 
 %files lockd
 %{_sbindir}/lvmlockd
@@ -311,18 +331,29 @@ Requires(preun): lvm2 >= 2.02
 Extensions to LVM2 to support clusters.
 
 %post cluster
-/sbin/chkconfig --add clvmd
-
-if [ "$1" -gt "1" ] ; then
-	/usr/sbin/clvmd -S >/dev/null 2>&1 || :
+%daemon_reload
+%enable -s clvmd -t service
+%if %{have_service clvmd}
+if [ $1 = 2 ]; then
+	if [ -e %{_default_pid_dir}/clvmd.pid ]; then
+		%{_sbindir}/clvmd -S >/dev/null 2>&1 || :
+	fi
 fi
+%endif
 
 %preun cluster
-if [ "$1" = 0 ]; then
-	/sbin/chkconfig --del clvmd
-        # lvmconf may no longer exist if lvm2 is being removed in the same rpm run
+%disable -s clvmd -t service
+%if %{have_service clvmd}
+if [ $1 = 0 ]; then
+	# lvmconf may no longer exist if lvm2 is being removed in the same rpm run
 	if test -x /sbin/lvmconf; then /sbin/lvmconf --disable-cluster; fi
 fi
+%endif
+
+%postun cluster
+if [ $1 = 0 ]; then
+%daemon_reload
+fi
 
 %files cluster
 %defattr(-,root,root,-)
@@ -355,11 +386,16 @@ Requires: device-mapper >= %{device_mapper_version}-%{release}
 Daemon providing device-mapper-based mirrors in a shared-storage cluster.
 
 %post -n cmirror
-/sbin/chkconfig --add cmirrord
+%daemon_reload
+%enable -s cmirrord -t service
 
 %preun -n cmirror
-if [ "$1" = 0 ]; then
-	/sbin/chkconfig --del cmirrord
+%disable -s cmirrord -t service
+
+%postun -n cmirror
+%try_restart -s cmirrord -t service
+if [ $1 = 0 ]; then
+%daemon_reload
 fi
 
 %files -n cmirror
@@ -468,26 +504,26 @@ This package contains the dmeventd daemon for monitoring the state
 of device-mapper devices.
 
 %post -n device-mapper-event
+%daemon_reload
 %if %{enable_systemd}
-/bin/systemctl daemon-reload > /dev/null 2>&1 || :
-/bin/systemctl enable dm-event.socket > /dev/null 2>&1 || :
+systemctl preset dm-event.socket > /dev/null 2>&1 || :
 %endif
+if [ -e %{_default_pid_dir}/dmeventd.pid ]; then
+        %{_sbindir}/dmeventd -R || echo "Failed to restart dmeventd daemon. Please, try manual restart."
+fi
 
 %preun -n device-mapper-event
 %if %{enable_systemd}
-if [ "$1" = 0 ]; then
-	/bin/systemctl --no-reload disable dm-event.service dm-event.socket > /dev/null 2>&1 || :
-	/bin/systemctl stop dm-event.service dm-event.socket> /dev/null 2>&1 || :
+if [ $1 = 0 ]; then
+	systemctl --no-reload disable dm-event.service dm-event.socket > /dev/null 2>&1 || :
+	systemctl stop dm-event.service dm-event.socket> /dev/null 2>&1 || :
 fi
 %endif
 
 %postun -n device-mapper-event
-%if %{enable_systemd}
-/bin/systemctl daemon-reload > /dev/null 2>&1 || :
-if [ $1 -ge 1 ]; then
-	/bin/systemctl reload dm-event.service > /dev/null 2>&1 || :
+if [ $1 = 0 ]; then
+%daemon_reload
 fi
-%endif
 
 %files -n device-mapper-event
 %defattr(-,root,root,-)
diff --git a/spec/source.inc b/spec/source.inc
index 2c17dbd..2681375 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -4,14 +4,31 @@
 # Defaults (rawhide)... 
 
 %global enable_profiling 0
-%global enable_testsuite 0
+%global enable_testsuite 1
 %global enable_udev 1
 %global enable_systemd 1
 %global enable_cmirror 1
-#%global enable_lvmlockd 0
+%global enable_lvmlockd 1
+%global enable_lvmetad 1
+%global enable_lvmpolld 1
 #%global enable_lockd_dlm 0
 #%global enable_lockd_sanlock 0
 
+%if %{enable_udev}
+%service lvmetad 1
+%service lvmpolld 1
+%endif
+
+########################################################
+# Normally clustering is maintained via resource agents
+#
+# enable service only if you know what you are doing
+#
+%if %{enable_cmirror}
+#service clvmd 1
+#service cmirrord 1
+%endif
+
 %global buildreq_cluster corosync-devel >= 1.99.9-1, dlm-devel >= 3.99.1-1
 %global req_cluster corosync >= 1.99.9-1, dlm >= 3.99.2-1
 %with clvmd corosync
@@ -26,9 +43,6 @@
 %global buildreq_udev systemd-devel
 %global req_udev udev >= 181-1
 
-%service lvmetad 1
-
-%service lvmpolld 1
 
 %if %{fedora} >= 22 || %{rhel} >= 7
  %service lvmlockd 1


