From: David Teigland <teigland@sourceware.org>
Date: Tue, 18 Apr 2017 12:22:41 -0400
Subject: master - spec: rename lockd to lvmlockd
Message-ID: <201704181622.v3IGMfeC020078@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a5256d1353ef60a3f29a7af1a9d1389bc7d64104
Commit:        a5256d1353ef60a3f29a7af1a9d1389bc7d64104
Parent:        a41a8430d6101af83160109f50df052aecc3818b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 18 11:22:07 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 18 11:22:07 2017 -0500

spec: rename lockd to lvmlockd

---
 spec/build.inc    |    4 ++--
 spec/packages.inc |    4 ++--
 spec/source.inc   |   22 +++++++++++-----------
 3 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/spec/build.inc b/spec/build.inc
index 88846c6..5321a70 100644
--- a/spec/build.inc
+++ b/spec/build.inc
@@ -27,8 +27,8 @@
 %enableif %{enable_lvmpolld} lvmpolld
 %global enable_lvmlockd %(if echo %{services} | grep -q lvmlockd; then echo 1; else echo 0; fi)
 %if %{enable_lvmlockd}
-%enableif %{enable_lockd_dlm} lockd-dlm
-%enableif %{enable_lockd_sanlock} lockd-sanlock
+%enableif %{enable_lvmlockd_dlm} lvmlockd-dlm
+%enableif %{enable_lvmlockd_sanlock} lvmlockd-sanlock
 %endif
 %enableif %{enable_python} python2-bindings
 %enableif %{enable_python3} python3-bindings
diff --git a/spec/packages.inc b/spec/packages.inc
index 74c4270..cdcc197 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -275,10 +275,10 @@ This package contains shared lvm2 libraries for applications.
 Summary: LVM locking daemon
 Group: System Environment/Base
 Requires: lvm2 = %{version}-%{release}
-%if %{enable_lockd_dlm}
+%if %{enable_lvmlockd_dlm}
 Requires: dlm-lib >= %{dlm_version}
 %endif
-%if %{enable_lockd_sanlock}
+%if %{enable_lvmlockd_sanlock}
 Requires: sanlock-lib >= %{sanlock_version}
 %endif
 Requires(post): systemd-units
diff --git a/spec/source.inc b/spec/source.inc
index a49b454..fb7ccf5 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -16,8 +16,8 @@
 %global enable_lvmetad 1
 %global enable_lvmpolld 1
 %global enable_dmfilemapd 0
-#%global enable_lockd_dlm 0
-#%global enable_lockd_sanlock 0
+#%global enable_lvmlockd_dlm 0
+#%global enable_lvmlockd_sanlock 0
 
 %if %{enable_udev}
 %service lvmetad 1
@@ -52,24 +52,24 @@
 %if %{fedora} >= 24 || %{rhel} >= 7
  %service lvmlockd 1
  %global sanlock_version 3.3.0-1
- %global enable_lockd_dlm 1
- %global enable_lockd_sanlock 1
+ %global enable_lvmlockd_dlm 1
+ %global enable_lvmlockd_sanlock 1
  %if %{rhel}
   %ifarch i686 x86_64 s390x
-   %global buildreq_lockd_dlm dlm-devel >= %{dlm_version}
+   %global buildreq_lvmlockd_dlm dlm-devel >= %{dlm_version}
   %else
-   %global enable_lockd_dlm 0
+   %global enable_lvmlockd_dlm 0
   %endif
   %ifarch x86_64 ppc64le ppc64 aarch64
-   %global buildreq_lockd_sanlock sanlock-devel >= %{sanlock_version}
+   %global buildreq_lvmlockd_sanlock sanlock-devel >= %{sanlock_version}
   %else
-   %global enable_lockd_sanlock 0
+   %global enable_lvmlockd_sanlock 0
   %endif
  %endif
 %else
  %if %{fedora} >= 22
   %service lvmlockd 1
-  %global enable_lockd_dlm 1
+  %global enable_lvmlockd_dlm 1
  %endif
 %endif
 
@@ -192,8 +192,8 @@ BuildRequires: pkgconfig
 
 %maybe BuildRequires: %{?buildreq_udev}
 %maybe BuildRequires: %{?buildreq_cluster}
-%maybe BuildRequires: %{?buildreq_lockd_dlm}
-%maybe BuildRequires: %{?buildreq_lockd_sanlock}
+%maybe BuildRequires: %{?buildreq_lvmlockd_dlm}
+%maybe BuildRequires: %{?buildreq_lvmlockd_sanlock}
 %maybe BuildRequires: %{?buildreq_python2_devel}
 %maybe BuildRequires: %{?buildreq_python3_devel}
 %maybe BuildRequires: %{?buildreq_python_setuptools}


