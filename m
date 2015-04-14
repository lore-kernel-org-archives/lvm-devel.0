From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 14 Apr 2015 08:12:04 +0000 (UTC)
Subject: master - tests: stacktrace understands fullpath
Message-ID: <20150414081204.4E08560E5E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c6bcfcba8541d053f142496c30f437a694daf5ee
Commit:        c6bcfcba8541d053f142496c30f437a694daf5ee
Parent:        c969e05aabb00b400d24e44c09c720f1cdebb351
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 14 09:48:57 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 14 10:11:36 2015 +0200

tests: stacktrace understands fullpath

$0 as name of script could be either relative or full path.
When it's fullpath don't prepend $TESTOLDPWD.
---
 test/lib/utils.sh |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 488e338..1713cc9 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -166,7 +166,9 @@ STACKTRACE() {
 			udevadm info --path "$i" || true
 		done | sed -e "s,^,## UDEV:     ,"
 		echo "<======== Script file \"$(< TESTNAME)\" ========>"
-		awk '{print "## Line:", NR, "\t", $0}' "$TESTOLDPWD/$0"
+		local script=$0
+		test -f "$script" || script="$TESTOLDPWD/$0"
+		awk '{print "## Line:", NR, "\t", $0}' "$script"
 	}
 
 	test -f SKIP_THIS_TEST && exit 200


