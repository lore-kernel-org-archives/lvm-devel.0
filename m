From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 28 Mar 2017 15:43:40 -0400
Subject: dev-mcsontos-spec-dmfilemapd - spec: Add dmfilemapd
Message-ID: <201703281943.v2SJhesf021256@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b84fa6f53a393685a178dcea89756643fff7f058
Commit:        b84fa6f53a393685a178dcea89756643fff7f058
Parent:        f0409c250eef2f77737f8c7a0685845d851c5bf7
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Mar 28 21:35:46 2017 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Mar 28 21:43:21 2017 +0200

spec: Add dmfilemapd

---
 spec/build.inc    |    1 +
 spec/packages.inc |    4 ++++
 spec/source.inc   |    7 +++++++
 3 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/spec/build.inc b/spec/build.inc
index cd58f3b..88846c6 100644
--- a/spec/build.inc
+++ b/spec/build.inc
@@ -34,6 +34,7 @@
 %enableif %{enable_python3} python3-bindings
 %enableif %{enable_python} applib
 %enableif %{enable_dbusd} dbus-service
+%enableif %{enable_dmfilemapd} dmfilemapd
 
 %build
 
diff --git a/spec/packages.inc b/spec/packages.inc
index cfe6736..74c4270 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -539,6 +539,10 @@ for the kernel device-mapper.
 %{_sbindir}/dmstats
 %{_mandir}/man8/dmsetup.8.gz
 %{_mandir}/man8/dmstats.8.gz
+%if %{enable_dmfilemapd}
+%{_sbindir}/dmfilemapd
+%{_mandir}/man8/dmfilemapd.8.gz
+%endif
 %if %{enable_udev}
 %doc udev/12-dm-permissions.rules
 %dir %{_udevbasedir}
diff --git a/spec/source.inc b/spec/source.inc
index 30a706c..a49b454 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -15,6 +15,7 @@
 %global enable_lvmlockd 1
 %global enable_lvmetad 1
 %global enable_lvmpolld 1
+%global enable_dmfilemapd 0
 #%global enable_lockd_dlm 0
 #%global enable_lockd_sanlock 0
 
@@ -93,6 +94,12 @@
 
 ##############################################################
 
+%if %{rhel} >= 7 || %{fedora} >= 25
+  %global enable_dmfilemapd 1
+%endif
+
+##############################################################
+
 %if %{rhel} >= 8 || %{fedora} >= 23
   %if %{enable_python3}
     %global enable_dbusd 1


