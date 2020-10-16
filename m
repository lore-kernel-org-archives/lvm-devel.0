From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:16 +0000 (GMT)
Subject: stable-2.02 - tests: disable dbustest with valgrind testing
Message-ID: <20201016191116.B5C97396EC85@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=57585ebacd54d7d0f4e80cf11e062e652d019539
Commit:        57585ebacd54d7d0f4e80cf11e062e652d019539
Parent:        8ad7c344cd06e14f40bd66a98315db68665cd79e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 10 16:39:07 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:58 2020 +0200

tests: disable dbustest with valgrind testing

---
 test/api/dbustest.sh | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/test/api/dbustest.sh b/test/api/dbustest.sh
index 9da4fe069..f7d2e91a8 100644
--- a/test/api/dbustest.sh
+++ b/test/api/dbustest.sh
@@ -16,7 +16,12 @@ SKIP_WITH_CLVMD=1
 
 . lib/inittest
 
-aux prepare_pvs 6
+# Unsupported with valgrid testing
+test ${LVM_VALGRIND:-0} -eq 0 || skip "Unsupported with valgrind"
+
+# NOTE: Some tests, namely anything with vdo, and
+# api/dbus_test_lv_interface_cache_lv.sh, require larger PVs
+aux prepare_pvs 6 6400
 
 # Required by test_nesting:
 aux extend_filter_LVMTEST


