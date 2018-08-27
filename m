From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon, 27 Aug 2018 10:18:27 -0400
Subject: 2018-06-01-stable - spec: Disable python bindings on newer versions
Message-ID: <201808271418.w7REIRMF017460@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=63d49838900cbd6d2f937d5ce75e70b32cf009a2
Commit:        63d49838900cbd6d2f937d5ce75e70b32cf009a2
Parent:        a991664dec02b62681a4a3eea7fbee2fc3a88700
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Aug 27 16:17:11 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Aug 27 16:17:11 2018 +0200

spec: Disable python bindings on newer versions

---
 spec/build.inc  |    1 +
 spec/source.inc |   22 +++++++++++-----------
 2 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/spec/build.inc b/spec/build.inc
index 5fb38f7..f317892 100644
--- a/spec/build.inc
+++ b/spec/build.inc
@@ -33,6 +33,7 @@
 %enableif %{enable_python} python2-bindings
 %enableif %{enable_python3} python3-bindings
 %enableif %{enable_python} applib
+%enableif %{enable_python3} applib
 %enableif %{enable_dbusd} dbus-service
 %enableif %{enable_dbusd} notify-dbus
 %enableif %{enable_dmfilemapd} dmfilemapd
diff --git a/spec/source.inc b/spec/source.inc
index fb7ccf5..93f9c7b 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -79,15 +79,24 @@
 %global enable_python 0
 %endif
 
-%if %{rhel} >= 8 || %{fedora} >= 20
+%if %{rhel} > 7 || %{fedora} >= 20
 %global enable_python3 1
 %endif
 
+%if %{rhel} > 7 || %{fedora} >= 29
+%global enable_python 0
+%endif
+
+%if %{rhel} > 7 || %{fedora} >= 23
+%global enable_dbusd 1
+%endif
+
 %if %{enable_python}
   %global buildreq_python2_devel python2-devel
   %global buildreq_python_setuptools python-setuptools
 %endif
-%if %{enable_python3}
+
+%if %{enable_python3} || %{enable_dbusd}
   %global buildreq_python3_devel python3-devel
   %global buildreq_python_setuptools python-setuptools
 %endif
@@ -100,15 +109,6 @@
 
 ##############################################################
 
-%if %{rhel} >= 8 || %{fedora} >= 23
-  %if %{enable_python3}
-    %global enable_dbusd 1
-  %else
-    # dbusd requires python3
-    false
-  %endif
-%endif
-
 %if %{enable_dbusd}
   %global buildreq_python3_dbus python3-dbus
   %global buildreq_python3_pyudev python3-pyudev


