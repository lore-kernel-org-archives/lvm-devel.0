From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 16 Mar 2017 08:05:17 -0400
Subject: master - spec: Use %global instead of %define for constants
Message-ID: <201703161205.v2GC5HpV009073@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7067514c9b3e5af88629799a4bd60614ef776a9d
Commit:        7067514c9b3e5af88629799a4bd60614ef776a9d
Parent:        5ba82a16db75a882b886b124c5f893a0ab636ba6
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Sep 16 17:23:32 2016 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Mar 16 13:03:24 2017 +0100

spec: Use %global instead of %define for constants

Using %define is now discouraged by Fedora Packaging Guidelines
---
 spec/source.inc |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/spec/source.inc b/spec/source.inc
index 3fa8038..43bb20c 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -50,19 +50,19 @@
 
 %if %{fedora} >= 24 || %{rhel} >= 7
  %service lvmlockd 1
- %define sanlock_version 3.3.0-1
- %define enable_lockd_dlm 1
- %define enable_lockd_sanlock 1
+ %global sanlock_version 3.3.0-1
+ %global enable_lockd_dlm 1
+ %global enable_lockd_sanlock 1
  %if %{rhel}
   %ifarch i686 x86_64 s390x
    %global buildreq_lockd_dlm dlm-devel >= %{dlm_version}
   %else
-   %define enable_lockd_dlm 0
+   %global enable_lockd_dlm 0
   %endif
   %ifarch x86_64 ppc64le ppc64 aarch64
    %global buildreq_lockd_sanlock sanlock-devel >= %{sanlock_version}
   %else
-   %define enable_lockd_sanlock 0
+   %global enable_lockd_sanlock 0
   %endif
  %endif
 %endif
@@ -140,7 +140,7 @@
 # same as FC 16 above, only with older udev
 
 %if %{rhel} == 6
-%define req_udev udev >= 147-2
+%global req_udev udev >= 147-2
 %global req_dm_persistent device-mapper-persistent-data >= 0.1.4
 %endif
 
@@ -149,7 +149,7 @@
 # Do not reset Release to 1 unless both lvm2 and device-mapper
 # versions are increased together.
 
-%define device_mapper_version 1.02.97
+%global device_mapper_version 1.02.97
 
 Summary: Userland logical volume management tools
 Name: lvm2


