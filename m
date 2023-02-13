From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Feb 2023 13:31:38 +0000 (GMT)
Subject: main - tests: use PWD for dbus testing
Message-ID: <20230213133138.5EBBD3858436@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8630a19d1e37e2f7e532c75ec26b7d1b071f1f8d
Commit:        8630a19d1e37e2f7e532c75ec26b7d1b071f1f8d
Parent:        7ea62f640cbe41b981c56ee334d6924da3bb3c0a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 13 14:29:38 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 13 14:30:43 2023 +0100

tests: use PWD for dbus testing

lvmdbusd ATM is leaking too many log files.
At least try to keep them removed with test failure.
---
 test/api/dbustest.sh | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/test/api/dbustest.sh b/test/api/dbustest.sh
index f4c9c9c2a..d69c0e89c 100644
--- a/test/api/dbustest.sh
+++ b/test/api/dbustest.sh
@@ -31,6 +31,8 @@ aux extend_filter_LVMTEST
 # output
 aux prepare_profiles "lvmdbusd"
 
+# Keep generating test file within test dir
+export TMPDIR=$PWD
 aux prepare_lvmdbusd
 
 # Example for testing individual test:

