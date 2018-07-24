From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 24 Jul 2018 10:24:30 -0400
Subject: master - spec: Fix conditional
Message-ID: <201807241424.w6OEOUWg016069@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=706606627f9b1ca75bb49466ae9aee04d858c2d9
Commit:        706606627f9b1ca75bb49466ae9aee04d858c2d9
Parent:        5ff18f51b9d004075b7185218afa6e7a74a88277
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Jul 24 16:22:23 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Jul 24 16:22:23 2018 +0200

spec: Fix conditional

---
 spec/packages.inc |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 702288c..38f90ec 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -165,7 +165,7 @@ fi
 %{_sysconfdir}/lvm/profile/cache-mq.profile
 %{_sysconfdir}/lvm/profile/cache-smq.profile
 %{_sysconfdir}/lvm/profile/lvmdbusd.profile
-%if %{enable_vdo}
+%if %{have_with vdo}
  %{_sysconfdir}/lvm/profile/vdo-small.profile
 %endif
 %dir %{_sysconfdir}/lvm/backup
@@ -240,7 +240,7 @@ This package contains shared lvm2 libraries for applications.
 %{_libdir}/libdevmapper-event-lvm2mirror.so
 %{_libdir}/libdevmapper-event-lvm2snapshot.so
 %{_libdir}/libdevmapper-event-lvm2raid.so
-%if %{enable_vdo}
+%if %{have_with vdo}
 %{_libdir}/device-mapper/libdevmapper-event-lvm2vdo.so
 %{_libdir}/libdevmapper-event-lvm2vdo.so
 %endif


