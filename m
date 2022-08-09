From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue,  9 Aug 2022 14:18:02 +0000 (GMT)
Subject: main - spec: Use libedit for newer distributions
Message-ID: <20220809141802.22DD3385AC23@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9cdd258646d5d9da534568a61133e76f3d5548d7
Commit:        9cdd258646d5d9da534568a61133e76f3d5548d7
Parent:        2fa99164938d11221fe6afc30af4f016bbc02450
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Jul 27 18:02:01 2022 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Aug 9 16:17:36 2022 +0200

spec: Use libedit for newer distributions

---
 spec/build.inc  |  2 ++
 spec/source.inc | 13 +++++++++++++
 2 files changed, 15 insertions(+)

diff --git a/spec/build.inc b/spec/build.inc
index 8067e58d0..e57ecf958 100644
--- a/spec/build.inc
+++ b/spec/build.inc
@@ -28,6 +28,8 @@
 %enableif %{enable_dbusd} dbus-service
 %enableif %{enable_dbusd} notify-dbus
 %enableif %{enable_dmfilemapd} dmfilemapd
+%enableif %{enable_readline} readline
+%enableif %{enable_editline} editline
 
 %build
 
diff --git a/spec/source.inc b/spec/source.inc
index d608debab..3e7573025 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -47,6 +47,14 @@
 %global req_udev udev >= 181-1
 
 
+%if %{fedora} >= 35 || %{rhel} >= 9
+  %global enable_readline 0
+  %global enable_editline 1
+%else
+  %global enable_readline 1
+  %global enable_editline 0
+%endif
+
 %if %{fedora} >= 24 || %{rhel} >= 7
  %service lvmlockd 1
  %global sanlock_version 3.3.0-1
@@ -154,7 +162,12 @@ Source94: macros.inc
 
 BuildRequires: libselinux-devel >= 1.30.19-4, libsepol-devel
 BuildRequires: ncurses-devel
+%if %{enable_readline}
 BuildRequires: readline-devel
+%endif
+%if %{enable_editline}
+BuildRequires: libedit-devel
+%endif
 BuildRequires: module-init-tools
 BuildRequires: pkgconfig
 

