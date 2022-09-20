From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 20 Sep 2022 14:34:31 +0000 (GMT)
Subject: master - spec: Workaround for failing build
Message-ID: <20220920143431.678E23858014@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=178564317a7c47d025ce268abe1bba01d1b4a519
Commit:        178564317a7c47d025ce268abe1bba01d1b4a519
Parent:        868665766491d9d42b8acedaf07cafc7118d165c
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Sep 20 15:12:44 2022 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Sep 20 15:12:44 2022 +0200

spec: Workaround for failing build

Commit 18722dfdf4d3e6f172d0b2af8bbdc4a154ea1dc0 introduced a dependency
on file from tools/ into lib/.

TODO: revert this once the issue is resolved.
---
 spec/build.inc | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/spec/build.inc b/spec/build.inc
index e57ecf958..e5f76db10 100644
--- a/spec/build.inc
+++ b/spec/build.inc
@@ -33,7 +33,8 @@
 
 %build
 
-%configure %{configure_flags}
+# FIXME: Remove --enable-dependency-tracking once problem with generated file from tools/ is used in lib/
+%configure %{configure_flags} --enable-dependency-tracking
 
 make %{?_smp_mflags}
 %{?extra_build_commands}

