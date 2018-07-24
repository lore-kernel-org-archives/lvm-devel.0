From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 24 Jul 2018 09:41:59 -0400
Subject: master - spec: Add vdo files
Message-ID: <201807241341.w6ODfxZ2002300@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=279f3bfdc00883a9ff3ea11fd7c6cc5455a58519
Commit:        279f3bfdc00883a9ff3ea11fd7c6cc5455a58519
Parent:        97506a7e2ac4cd4e9a6fd77e4a49a45fd565c3e5
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Jul 24 15:37:15 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Jul 24 15:41:30 2018 +0200

spec: Add vdo files

---
 spec/packages.inc |    7 +++++++
 spec/source.inc   |    2 ++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index ba9bd47..702288c 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -165,6 +165,9 @@ fi
 %{_sysconfdir}/lvm/profile/cache-mq.profile
 %{_sysconfdir}/lvm/profile/cache-smq.profile
 %{_sysconfdir}/lvm/profile/lvmdbusd.profile
+%if %{enable_vdo}
+ %{_sysconfdir}/lvm/profile/vdo-small.profile
+%endif
 %dir %{_sysconfdir}/lvm/backup
 %dir %{_sysconfdir}/lvm/cache
 %dir %{_sysconfdir}/lvm/archive
@@ -237,6 +240,10 @@ This package contains shared lvm2 libraries for applications.
 %{_libdir}/libdevmapper-event-lvm2mirror.so
 %{_libdir}/libdevmapper-event-lvm2snapshot.so
 %{_libdir}/libdevmapper-event-lvm2raid.so
+%if %{enable_vdo}
+%{_libdir}/device-mapper/libdevmapper-event-lvm2vdo.so
+%{_libdir}/libdevmapper-event-lvm2vdo.so
+%endif
 
 
 ##############################################################################
diff --git a/spec/source.inc b/spec/source.inc
index 05eb9c2..4561e8a 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -37,6 +37,8 @@
 %with thin_check %{_sbindir}/thin_check
 %with thin_repair %{_sbindir}/thin_repair
 %with thin_dump %{_sbindir}/thin_dump
+%with vdo internal
+%with vdo-format %{_bindir}/vdoformat
 
 %global buildreq_udev systemd-devel
 %global req_udev udev >= 181-1


