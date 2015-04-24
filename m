From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Apr 2015 22:42:27 +0000 (UTC)
Subject: master - tests: allow add printable skip message
Message-ID: <20150424224227.4792F60FBE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f50229041bfc9570aeae0eef614f1e68f157802e
Commit:        f50229041bfc9570aeae0eef614f1e68f157802e
Parent:        a939857a63e7e119e6a4ce0f749cf981a196aabc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 24 20:32:21 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Apr 25 00:40:02 2015 +0200

tests: allow add printable skip message

---
 test/lib/utils.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index a610632..80e5922 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -209,6 +209,7 @@ dm_table() {
 }
 
 skip() {
+	test "$#" -eq 0 || echo "TEST SKIPPED: $@"
 	touch SKIP_THIS_TEST
 	exit 200
 }


