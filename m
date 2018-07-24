From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 24 Jul 2018 09:00:36 -0400
Subject: master - spec: Remove python bindings
Message-ID: <201807241300.w6OD0a3D017822@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=86c3940537092cee3e1899e065bcc36ddc0236be
Commit:        86c3940537092cee3e1899e065bcc36ddc0236be
Parent:        bf4be8066974d8a41bbb9012bd6ba8c8595d2d9c
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Jul 24 14:55:32 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Jul 24 14:55:32 2018 +0200

spec: Remove python bindings

---
 spec/build.inc  |    3 ---
 spec/source.inc |   32 +++-----------------------------
 2 files changed, 3 insertions(+), 32 deletions(-)

diff --git a/spec/build.inc b/spec/build.inc
index 41cf01e..a630bb7 100644
--- a/spec/build.inc
+++ b/spec/build.inc
@@ -28,9 +28,6 @@
 %enableif %{enable_lvmlockd_dlm} lvmlockd-dlm
 %enableif %{enable_lvmlockd_sanlock} lvmlockd-sanlock
 %endif
-%enableif %{enable_python} python2-bindings
-%enableif %{enable_python3} python3-bindings
-%enableif %{enable_python} applib
 %enableif %{enable_dbusd} dbus-service
 %enableif %{enable_dbusd} notify-dbus
 %enableif %{enable_dmfilemapd} dmfilemapd
diff --git a/spec/source.inc b/spec/source.inc
index c44d6bc..b23e3b6 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -5,9 +5,6 @@
 
 %global enable_profiling 0
 %global enable_testsuite 1
-%global enable_python 1
-# Off by default - <= does not work well with or:
-%global enable_python3 0
 %global enable_dbusd 0
 %global enable_udev 1
 %global enable_systemd 1
@@ -72,25 +69,6 @@
 
 ##############################################################
 
-%if %{rhel} == 5
-%global enable_python 0
-%endif
-
-%if %{rhel} >= 8 || %{fedora} >= 20
-%global enable_python3 1
-%endif
-
-%if %{enable_python}
-  %global buildreq_python2_devel python2-devel
-  %global buildreq_python_setuptools python-setuptools
-%endif
-%if %{enable_python3}
-  %global buildreq_python3_devel python3-devel
-  %global buildreq_python_setuptools python-setuptools
-%endif
-
-##############################################################
-
 %if %{rhel} >= 7 || %{fedora} >= 25
   %global enable_dmfilemapd 1
 %endif
@@ -98,15 +76,12 @@
 ##############################################################
 
 %if %{rhel} >= 8 || %{fedora} >= 23
-  %if %{enable_python3}
-    %global enable_dbusd 1
-  %else
-    # dbusd requires python3
-    false
-  %endif
+  %global enable_dbusd 1
 %endif
 
 %if %{enable_dbusd}
+  %global buildreq_python3_devel python3-devel
+  %global buildreq_python_setuptools python-setuptools
   %global buildreq_python3_dbus python3-dbus
   %global buildreq_python3_pyudev python3-pyudev
 %endif
@@ -191,7 +166,6 @@ BuildRequires: pkgconfig
 %maybe BuildRequires: %{?buildreq_cluster}
 %maybe BuildRequires: %{?buildreq_lvmlockd_dlm}
 %maybe BuildRequires: %{?buildreq_lvmlockd_sanlock}
-%maybe BuildRequires: %{?buildreq_python2_devel}
 %maybe BuildRequires: %{?buildreq_python3_devel}
 %maybe BuildRequires: %{?buildreq_python_setuptools}
 


