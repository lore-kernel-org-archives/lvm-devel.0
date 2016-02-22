From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Mon, 22 Feb 2016 16:50:58 +0000 (UTC)
Subject: master - spec: Fix 04ab1fa572bb: Remove left-overs
Message-ID: <20160222165058.9B7686053A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=367fb85e44e0718a335c328ca75cb646539d3148
Commit:        367fb85e44e0718a335c328ca75cb646539d3148
Parent:        c716813651c2691c44bc709040cd16fbf363a74e
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Feb 22 17:40:12 2016 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Feb 22 17:50:35 2016 +0100

spec: Fix 04ab1fa572bb: Remove left-overs

---
 spec/build.inc     |    5 -----
 test/api/pytest.sh |   16 ++++++++++++----
 2 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/spec/build.inc b/spec/build.inc
index 3ba7840..cd58f3b 100644
--- a/spec/build.inc
+++ b/spec/build.inc
@@ -55,11 +55,6 @@ make install_initscripts DESTDIR=$RPM_BUILD_ROOT
 %if %{enable_testsuite}
 make -C test install DESTDIR=$RPM_BUILD_ROOT
 %endif
-%if %{enable_python3}
-pushd %{py3dir}
-make -C python install DESTDIR=$RPM_BUILD_ROOT
-popd
-%endif
 
 # when building an src.rpm from freestanding specfiles
 test -e %{_sourcedir}/source.inc || cp source.inc build.inc packages.inc macros.inc %{_sourcedir}
diff --git a/test/api/pytest.sh b/test/api/pytest.sh
index 33c1095..28a1cd0 100644
--- a/test/api/pytest.sh
+++ b/test/api/pytest.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/bin/bash
 # Copyright (C) 2012-2015 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
@@ -31,9 +31,17 @@ aux prepare_dmeventd
 
 #Locate the python binding library to use.
 if [[ -n $abs_top_builddir ]]; then
-  python_lib=$(find $abs_top_builddir -name lvm.so)
-  # Unable to test python bindings if library not available
-  test -n "$python_lib" || skip "lvm2-python-libs not built"
+  python_lib=($(find $abs_top_builddir -name lvm.so))
+  if [[ ${#python_lib[*]} -ne 1 ]]; then
+    if [[ ${#python_lib[*]} -gt 1 ]]; then
+      # Unable to test python bindings if multiple libraries found:
+      echo "Found left over lvm.so: ${python_lib[*]}"
+      false
+    else
+      # Unable to test python bindings if library not available
+      skip "lvm2-python-libs not built"
+    fi
+  fi
 
   export PYTHONPATH=$(dirname $python_lib):$PYTHONPATH
 elif rpm -q lvm2-python-libs &>/dev/null; then


