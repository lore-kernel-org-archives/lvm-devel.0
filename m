From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:50 +0000 (UTC)
Subject: master - spec: Add an (optional) lvm2-testsuite subpackage.
Message-ID: <20150205134150.98A7060F11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d5537e7d6b28d2a7f2214529797aade0ed29efab
Commit:        d5537e7d6b28d2a7f2214529797aade0ed29efab
Parent:        d488f032298ee6e8bf3f0abc50e2756f11a73196
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 01:24:47 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:18 2015 +0100

spec: Add an (optional) lvm2-testsuite subpackage.

---
 spec/build.inc    |    3 +++
 spec/packages.inc |   15 +++++++++++++++
 spec/source.inc   |    1 +
 3 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/spec/build.inc b/spec/build.inc
index 95c9b83..176fdb1 100644
--- a/spec/build.inc
+++ b/spec/build.inc
@@ -37,6 +37,9 @@ make install_initscripts DESTDIR=$RPM_BUILD_ROOT
 make install_systemd_units DESTDIR=$RPM_BUILD_ROOT
 make install_tmpfiles_configuration DESTDIR=$RPM_BUILD_ROOT
 %endif
+%if %{enable_testsuite}
+make -C test install DESTDIR=$RPM_BUILD_ROOT
+%endif
 
 # when building an src.rpm from freestanding specfiles
 test -e %{_sourcedir}/source.inc || cp source.inc build.inc packages.inc macros.inc %{_sourcedir}
diff --git a/spec/packages.inc b/spec/packages.inc
index f0b7cfd..d368838 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -494,3 +494,18 @@ the device-mapper event library.
 %{_includedir}/libdevmapper-event.h
 %{_libdir}/pkgconfig/devmapper-event.pc
 
+%if %{enable_testsuite}
+%package testsuite
+Summary: LVM2 Testsuite
+License: LGPLv2
+Group: Development
+
+%description testsuite
+An extensive functional testsuite for LVM2.
+
+%files testsuite
+%defattr(-,root,root,-)
+%{_datadir}/lvm2-testsuite/
+%{_libexecdir}/lvm2-testsuite/
+%{_bindir}/lvm2-testsuite
+%endif
diff --git a/spec/source.inc b/spec/source.inc
index 6ef4791..21fbf7d 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -4,6 +4,7 @@
 # Defaults (rawhide)... 
 
 %global enable_profiling 0
+%global enable_testsuite 0
 %global enable_udev 1
 %global enable_systemd 1
 %global enable_cmirror 1


