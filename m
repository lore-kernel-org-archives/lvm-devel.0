From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Tue,  7 Jul 2015 15:00:15 +0000 (UTC)
Subject: master - spec: Update to use enable_lockd_*
Message-ID: <20150707150015.7246561110@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=181e701cc51af20c599998358a49902228cb65c1
Commit:        181e701cc51af20c599998358a49902228cb65c1
Parent:        a421879bb5da8b32141cec851c490a1ce9906e6d
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Jul 7 14:54:57 2015 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Jul 7 16:53:19 2015 +0200

spec: Update to use enable_lockd_*

---
 spec/build.inc  |    5 ++++-
 spec/source.inc |   22 +++++++++++++++++++++-
 2 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/spec/build.inc b/spec/build.inc
index db9bcc2..94d5e06 100644
--- a/spec/build.inc
+++ b/spec/build.inc
@@ -7,7 +7,10 @@
 %global enable_lvmpolld %(if echo %{services} | grep -q lvmpolld; then echo 1; else echo 0; fi)
 %enableif %{enable_lvmpolld} lvmpolld
 %global enable_lvmlockd %(if echo %{services} | grep -q lvmlockd; then echo 1; else echo 0; fi)
-%enableif %{enable_lvmlockd} lvmlockd
+%if %{enable_lvmlockd}
+%enableif %{enable_lockd_dlm} lockd-dlm
+%enableif %{enable_lockd_sanlock} lockd-sanlock
+%endif
 
 %build
 %configure \
diff --git a/spec/source.inc b/spec/source.inc
index 0a0d9e5..2c17dbd 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -8,6 +8,9 @@
 %global enable_udev 1
 %global enable_systemd 1
 %global enable_cmirror 1
+#%global enable_lvmlockd 0
+#%global enable_lockd_dlm 0
+#%global enable_lockd_sanlock 0
 
 %global buildreq_cluster corosync-devel >= 1.99.9-1, dlm-devel >= 3.99.1-1
 %global req_cluster corosync >= 1.99.9-1, dlm >= 3.99.2-1
@@ -28,7 +31,22 @@
 %service lvmpolld 1
 
 %if %{fedora} >= 22 || %{rhel} >= 7
-%service lvmlockd 1
+ %service lvmlockd 1
+ %define sanlock_version 3.2.4-1
+ %define enable_lockd_dlm 1
+ %define enable_lockd_sanlock 1
+ %if %{rhel}
+  %ifarch i686 x86_64 s390x
+   %global buildreq_lockd_dlm dlm-devel >= %{dlm_version}
+  %else
+   %define enable_lockd_dlm 0
+  %endif
+  %ifarch x86_64 ppc64le ppc64 aarch64
+   %global buildreq_lockd_sanlock sanlock-devel >= %{sanlock_version}
+  %else
+   %define enable_lockd_sanlock 0
+  %endif
+ %endif
 %endif
 
 ##############################################################
@@ -109,6 +127,8 @@ BuildRequires: pkgconfig
 
 %maybe BuildRequires: %{?buildreq_udev}
 %maybe BuildRequires: %{?buildreq_cluster}
+%maybe BuildRequires: %{?buildreq_lockd_dlm}
+%maybe BuildRequires: %{?buildreq_lockd_sanlock}
 
 %description
 LVM2 includes all of the support for handling read/write operations on


