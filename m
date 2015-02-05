From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:58 +0000 (UTC)
Subject: master - test: Fix failures due to undefined abs_top_builddir.
Message-ID: <20150205134258.2F99E60E22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bd0806e1f53f4b978cf298885e1d98365011ec3e
Commit:        bd0806e1f53f4b978cf298885e1d98365011ec3e
Parent:        c6f9c4622378a312f0195ab968f8744b881d10b5
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Sep 15 00:19:53 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:21 2015 +0100

test: Fix failures due to undefined abs_top_builddir.

---
 test/shell/000-basic.sh        |    2 ++
 test/shell/dmeventd-restart.sh |    5 ++++-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/test/shell/000-basic.sh b/test/shell/000-basic.sh
index 7ad4d9f..027969e 100644
--- a/test/shell/000-basic.sh
+++ b/test/shell/000-basic.sh
@@ -13,6 +13,8 @@
 
 lvm version
 
+test -n "$abs_top_builddir" || skip
+
 v=$abs_top_builddir/lib/misc/lvm-version.h
 sed -n "/#define LVM_VERSION ./s///p" "$v" | sed "s/ .*//" > expected
 
diff --git a/test/shell/dmeventd-restart.sh b/test/shell/dmeventd-restart.sh
index a94ede1..4344e82 100644
--- a/test/shell/dmeventd-restart.sh
+++ b/test/shell/dmeventd-restart.sh
@@ -43,7 +43,10 @@ not pgrep dmeventd
 rm LOCAL_DMEVENTD
 
 # set dmeventd path
-aux lvmconf "dmeventd/executable=\"$abs_top_builddir/test/lib/dmeventd\""
+if test -n "$abs_top_builddir"; then
+    aux lvmconf "dmeventd/executable=\"$abs_top_builddir/test/lib/dmeventd\""
+fi
+
 lvchange --monitor y --verbose $vg/3way 2>&1 | tee lvchange.out
 pgrep dmeventd >LOCAL_DMEVENTD
 not grep 'already monitored' lvchange.out


