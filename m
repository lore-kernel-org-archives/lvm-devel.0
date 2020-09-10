From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 10 Sep 2020 21:56:21 +0000 (GMT)
Subject: master - tests: disable dbustest with valgrind testing
Message-ID: <20200910215621.5E739398544D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3dcd61d3d797e3ed12e934f1fa7064153e2fdb71
Commit:        3dcd61d3d797e3ed12e934f1fa7064153e2fdb71
Parent:        678951f635616fc54896717af1183092a0556a3f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 10 16:39:07 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 10 23:55:03 2020 +0200

tests: disable dbustest with valgrind testing

---
 test/api/dbustest.sh | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/test/api/dbustest.sh b/test/api/dbustest.sh
index 8aa0ce068..f7d2e91a8 100644
--- a/test/api/dbustest.sh
+++ b/test/api/dbustest.sh
@@ -16,6 +16,9 @@ SKIP_WITH_CLVMD=1
 
 . lib/inittest
 
+# Unsupported with valgrid testing
+test ${LVM_VALGRIND:-0} -eq 0 || skip "Unsupported with valgrind"
+
 # NOTE: Some tests, namely anything with vdo, and
 # api/dbus_test_lv_interface_cache_lv.sh, require larger PVs
 aux prepare_pvs 6 6400


