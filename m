From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 18 Dec 2019 09:35:48 -0500
Subject: master - tests: Some lvmdbus tests require larger PVs
Message-ID: <49642.119121809354301057@us-mta-80.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=87e88078c993a149af6d2f104998c508b7aee9be
Commit:        87e88078c993a149af6d2f104998c508b7aee9be
Parent:        a2a993d99558a719b0f4450e7b2fc8fc43bb5962
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Dec 18 15:33:58 2019 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Dec 18 15:33:58 2019 +0100

tests: Some lvmdbus tests require larger PVs

---
 test/api/dbustest.sh |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/test/api/dbustest.sh b/test/api/dbustest.sh
index 9da4fe0..8aa0ce0 100644
--- a/test/api/dbustest.sh
+++ b/test/api/dbustest.sh
@@ -16,7 +16,9 @@ SKIP_WITH_CLVMD=1
 
 . lib/inittest
 
-aux prepare_pvs 6
+# NOTE: Some tests, namely anything with vdo, and
+# api/dbus_test_lv_interface_cache_lv.sh, require larger PVs
+aux prepare_pvs 6 6400
 
 # Required by test_nesting:
 aux extend_filter_LVMTEST



