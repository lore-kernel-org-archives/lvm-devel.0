From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:57:40 +0000 (UTC)
Subject: master - tests: add helper funcionality for using gdb
Message-ID: <20140924085740.2AF60610D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=21aa850b43535ab251eebabe2a2773a62439bf61
Commit:        21aa850b43535ab251eebabe2a2773a62439bf61
Parent:        9acbb0695f96a400f2be6c1c5bf76b914653c200
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 21 01:16:57 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:54:48 2014 +0200

tests: add helper funcionality for using gdb

When there is need for using gdb within test suite
just prefix command with LVM_DBG and run test in
standard shell (for stdin).
---
 test/lib/lvm-wrapper.sh |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/test/lib/lvm-wrapper.sh b/test/lib/lvm-wrapper.sh
index c69e29a..082c640 100644
--- a/test/lib/lvm-wrapper.sh
+++ b/test/lib/lvm-wrapper.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2011-2012 Red Hat, Inc.
+# Copyright (C) 2011-2014 Red Hat, Inc.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -14,6 +14,13 @@
 CMD=${0##*/}
 test "$CMD" != lvm || unset CMD
 
+# When needed to trace command from test suite use env var before program
+# and run program directly via shell in test dir i.e.:
+# sh shell/activate-mirror.sh
+# 'LVM_GDB=1 lvcreate -l1 $vg'
+# > run
+test -z "$LVM_GDB" || exec gdb --readnow --args "$abs_top_builddir/tools/lvm" $CMD "$@"
+
 # Multiple level of LVM_VALGRIND support
 # the higher level the more commands are traced
 if test -n "$LVM_VALGRIND"; then


