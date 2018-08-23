From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 23 Aug 2018 05:29:55 -0400
Subject: 2018-06-01-stable - spec: Add vdo plugin for dmeventd
Message-ID: <201808230929.w7N9TtUM011288@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=94362423c47fc8bc8a06354cffdf91113a74035b
Commit:        94362423c47fc8bc8a06354cffdf91113a74035b
Parent:        acf40f55873f8dc38d7cfd3c121667dac33409f6
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Aug 23 11:27:17 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Aug 23 11:27:17 2018 +0200

spec: Add vdo plugin for dmeventd

---
 spec/packages.inc |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index cdcc197..f7a9232 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -258,6 +258,7 @@ This package contains shared lvm2 libraries for applications.
 %{_libdir}/device-mapper/libdevmapper-event-lvm2mirror.so
 %{_libdir}/device-mapper/libdevmapper-event-lvm2snapshot.so
 %{_libdir}/device-mapper/libdevmapper-event-lvm2raid.so
+%{_libdir}/device-mapper/libdevmapper-event-lvm2vdo.so
 %if %{have_with thin}
 %{_libdir}/device-mapper/libdevmapper-event-lvm2thin.so
 %{_libdir}/libdevmapper-event-lvm2thin.so
@@ -265,6 +266,7 @@ This package contains shared lvm2 libraries for applications.
 %{_libdir}/libdevmapper-event-lvm2mirror.so
 %{_libdir}/libdevmapper-event-lvm2snapshot.so
 %{_libdir}/libdevmapper-event-lvm2raid.so
+%{_libdir}/libdevmapper-event-lvm2vdo.so
 
 
 ##############################################################################


