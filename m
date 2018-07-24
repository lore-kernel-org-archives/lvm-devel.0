From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 24 Jul 2018 08:51:23 -0400
Subject: master - spec: Remove lvmetad
Message-ID: <201807241251.w6OCpNWl016926@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bf4be8066974d8a41bbb9012bd6ba8c8595d2d9c
Commit:        bf4be8066974d8a41bbb9012bd6ba8c8595d2d9c
Parent:        2214dc12c34890c78b05456f58d0aa5d6dd08f4c
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Jul 24 14:50:52 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Jul 24 14:50:52 2018 +0200

spec: Remove lvmetad

---
 spec/build.inc    |    2 --
 spec/packages.inc |   24 ------------------------
 spec/source.inc   |    2 --
 3 files changed, 0 insertions(+), 28 deletions(-)

diff --git a/spec/build.inc b/spec/build.inc
index 5fb38f7..41cf01e 100644
--- a/spec/build.inc
+++ b/spec/build.inc
@@ -21,8 +21,6 @@
 %enableif %{enable_cmirror} cmirrord
 %enableif %{enable_udev} udev_sync
 %enableif %{enable_profiling} profiling
-%global enable_lvmetad %(if echo %{services} | grep -q lvmetad; then echo 1; else echo 0; fi)
-%enableif %{enable_lvmetad} lvmetad
 %global enable_lvmpolld %(if echo %{services} | grep -q lvmpolld; then echo 1; else echo 0; fi)
 %enableif %{enable_lvmpolld} lvmpolld
 %global enable_lvmlockd %(if echo %{services} | grep -q lvmlockd; then echo 1; else echo 0; fi)
diff --git a/spec/packages.inc b/spec/packages.inc
index bf2432a..ba9bd47 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -3,9 +3,6 @@
 %post
 %daemon_reload
 %enable -s monitor -t service
-%if %{have_service lvmetad}
-%enable -s lvmetad -t socket
-%endif
 %if %{have_service lvmpolld}
 %enable -s lvmpolld -t socket
 %endif
@@ -14,16 +11,10 @@
 %if %{have_service lvmpolld}
 %disable -s lvmpolld -t socket
 %endif
-%if %{have_service lvmetad}
-%disable -s lvmetad -t socket
-%endif
 %disable -s monitor -t service
 
 %postun
 %try_restart -s monitor -t service
-%if %{have_service lvmetad}
-%try_restart -s lvmetad -t service
-%endif
 %if %{have_service lvmpolld}
 %try_restart -s lvmpolld -t service
 %endif
@@ -90,9 +81,6 @@ fi
 %{_sbindir}/vgs
 %{_sbindir}/vgscan
 %{_sbindir}/vgsplit
-%if %{have_service lvmetad}
- %{_sbindir}/lvmetad
-%endif
 %if %{have_service lvmpolld}
  %{_sbindir}/lvmpolld
 %endif
@@ -164,10 +152,6 @@ fi
 %endif
 %if %{enable_udev}
  %{_udevdir}/11-dm-lvm.rules
- %if %{have_service lvmetad}
-  %{_mandir}/man8/lvmetad.8.gz
-  %{_udevdir}/69-dm-lvm-metad.rules
- %endif
 %endif
 %dir %{_sysconfdir}/lvm
 %ghost %{_sysconfdir}/lvm/cache/.cache
@@ -191,11 +175,6 @@ fi
  %{_unitdir}/blk-availability.service
  %{_unitdir}/lvm2-monitor.service
  %attr(555, -, -) %{_prefix}/lib/systemd/system-generators/lvm2-activation-generator
- %if %{have_service lvmetad}
-  %{_unitdir}/lvm2-lvmetad.socket
-  %{_unitdir}/lvm2-lvmetad.service
-  %{_unitdir}/lvm2-pvscan at .service
- %endif
  %if %{have_service lvmpolld}
   %{_unitdir}/lvm2-lvmpolld.service
   %{_unitdir}/lvm2-lvmpolld.socket
@@ -203,9 +182,6 @@ fi
 %else
  %{_sysconfdir}/rc.d/init.d/blk-availability
  %{_sysconfdir}/rc.d/init.d/lvm2-monitor
- %if %{have_service lvmetad}
-  %{_sysconfdir}/rc.d/init.d/lvm2-lvmetad
- %endif
  %if %{have_service lvmpolld}
   %{_sysconfdir}/rc.d/init.d/lvm2-lvmpolld
  %endif
diff --git a/spec/source.inc b/spec/source.inc
index 6a485ef..c44d6bc 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -13,14 +13,12 @@
 %global enable_systemd 1
 %global enable_cmirror 1
 %global enable_lvmlockd 1
-%global enable_lvmetad 1
 %global enable_lvmpolld 1
 %global enable_dmfilemapd 0
 #%global enable_lvmlockd_dlm 0
 #%global enable_lvmlockd_sanlock 0
 
 %if %{enable_udev}
-%service lvmetad 1
 %service lvmpolld 1
 %endif
 


