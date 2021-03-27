From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 27 Mar 2021 22:19:42 +0000 (GMT)
Subject: main - tests: use known path for test in find
Message-ID: <20210327221942.405433857C48@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=12222add1abb45ebbc0c6dfccb514bb75d4ae4ea
Commit:        12222add1abb45ebbc0c6dfccb514bb75d4ae4ea
Parent:        37d603268f98ba51d9fd9c734004274de8fcca1b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 27 21:33:28 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 27 23:18:38 2021 +0100

tests: use known path for test in find

Actually make sure which 'test' binary is executed.
Since we used to have 'test' binary in tests.
---
 test/lib/aux.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 0ce2b8b07..38191842d 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -582,7 +582,7 @@ teardown() {
 
 	# Remove any dangling symlink in /dev/disk (our tests can confuse udev)
 	test -d /dev/disk && {
-		find /dev/disk -type l ! -exec test -e {} \; -print | xargs rm -f || true
+		find /dev/disk -type l ! -exec /usr/bin/test -e {} \; -print | xargs rm -f || true
 	}
 
 	# Remove any metadata archives and backups from this test on system


