From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  9 Jun 2023 16:01:59 +0000 (GMT)
Subject: main - tests: tmp dir inside test dir
Message-ID: <20230609160159.2FF9E3858C52@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=734d9791f817693f1d6f396b34d105894aacb16c
Commit:        734d9791f817693f1d6f396b34d105894aacb16c
Parent:        4d648380484ecf58c33f92a84950bb0bf39424ef
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 29 14:17:43 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 9 18:01:16 2023 +0200

tests: tmp dir inside test dir

Keep even temporary files within testing dir so generated files are
not left behind in system's /tmp directory.
---
 test/lib/inittest.sh | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 9f2713062..c41f4c5b4 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -106,7 +106,7 @@ else
 fi
 
 cd "$TESTDIR"
-mkdir lib
+mkdir lib tmp
 
 # Setting up symlink from $i to $TESTDIR/lib
 test -n "${abs_top_builddir+varset}" && \
@@ -118,6 +118,7 @@ find "$TESTOLDPWD/lib" ! \( -name '*.sh' -o -name '*.[cdo]' \
 DM_DEFAULT_NAME_MANGLING_MODE=none
 DM_DEV_DIR="$TESTDIR/dev"
 LVM_SYSTEM_DIR="$TESTDIR/etc"
+TMPDIR="$TESTDIR/tmp"
 # abort on the internal dm errors in the tests (allowing test user override)
 DM_ABORT_ON_INTERNAL_ERRORS=${DM_ABORT_ON_INTERNAL_ERRORS:-1}
 DM_DEBUG_WITH_LINE_NUMBERS=${DM_DEBUG_WITH_LINE_NUMBERS:-1}

