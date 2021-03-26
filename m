From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 26 Mar 2021 12:18:06 +0000 (GMT)
Subject: main - tests: add commented example
Message-ID: <20210326121806.BFF733858024@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7768650d87d4086a76f1558aab4436acda1b5e44
Commit:        7768650d87d4086a76f1558aab4436acda1b5e44
Parent:        25c665d5559e77c1eb0f67527fa95419a84b7553
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 26 13:16:44 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 26 13:16:44 2021 +0100

tests: add commented example

How to run individual test.
---
 test/api/dbustest.sh | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/test/api/dbustest.sh b/test/api/dbustest.sh
index d922d903f..83e40d056 100644
--- a/test/api/dbustest.sh
+++ b/test/api/dbustest.sh
@@ -32,4 +32,8 @@ aux prepare_profiles "lvmdbusd"
 
 aux prepare_lvmdbusd
 
+# Example for testing individual test:
+#"$TESTOLDPWD/dbus/lvmdbustest.py" -v TestDbusService.test_lv_interface_cache_lv
+#"$TESTOLDPWD/dbus/lvmdbustest.py" -v TestDbusService.test_pv_symlinks
+
 "$TESTOLDPWD/dbus/lvmdbustest.py" -v


