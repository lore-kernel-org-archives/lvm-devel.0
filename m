From: Bryn Reeves <bmr@fedoraproject.org>
Date: Thu, 25 Feb 2016 16:51:41 +0000 (UTC)
Subject: master - tests: add basic dmstats tests
Message-ID: <20160225165141.C406D60E57@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1f8fd5a1522b607255eb8e45572a22de85d6f2ae
Commit:        1f8fd5a1522b607255eb8e45572a22de85d6f2ae
Parent:        985ed7822f2ac12724ef3bbd823644b0a74f400c
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Nov 26 17:11:40 2015 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Feb 25 16:40:58 2016 +0000

tests: add basic dmstats tests

Add initial dmstats tests to 000-basic.sh. These tests ensure that
the dmsetup binary is built and linked correctly when called as
'dmstats' and that the version of the binary matches the expected
library version used for the build.
---
 test/Makefile.in        |    3 +++
 test/shell/000-basic.sh |    5 +++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 915a0b0..c69b3b6 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -288,6 +288,9 @@ lib/paths: lib/paths-common
 lib/version-expected: $(top_srcdir)/VERSION .lib-dir-stamp
 	cut -f 1 -d ' ' <$< >$@
 
+lib/dm-version-expected: $(top_srcdir)/VERSION_DM .lib-dir-stamp
+	cut -f 1 -d ' ' <$< >$@
+
 CMDS = lvm $(shell cat $(top_builddir)/tools/.commands 2>/dev/null)
 LIB = $(addprefix lib/, $(LIB_SHARED) $(LIB_LOCAL) $(LIB_NOT) $(LIB_LINK_NOT) $(LIB_FLAVOURS))
 
diff --git a/test/shell/000-basic.sh b/test/shell/000-basic.sh
index d1c7dc8..da84f3e 100644
--- a/test/shell/000-basic.sh
+++ b/test/shell/000-basic.sh
@@ -21,6 +21,11 @@ lvm pvmove --version|sed -n "1s/.*: *\([0-9][^ ]*\) .*/\1/p" | tee version
 # ensure they are the same
 diff -u version lib/version-expected
 
+dmstats version |sed -n "1s/.*: *\([0-9][^ ]*\) .*/\1/p" | tee dmstats-version
+
+# ensure dmstats version matches build
+diff -u dmstats-version lib/dm-version-expected
+
 # ensure we can create devices (uses dmsetup, etc)
 aux prepare_devs 5
 


