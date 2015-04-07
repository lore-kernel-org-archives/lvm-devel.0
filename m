From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  7 Apr 2015 11:42:43 +0000 (UTC)
Subject: master - tests: when test fails collect more info
Message-ID: <20150407114243.24EB360F22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=64353ff74b56c71b508fd040a45062facb395bae
Commit:        64353ff74b56c71b508fd040a45062facb395bae
Parent:        ba049e203b35d6e03e38669a2a92af6538a0b2d0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 7 13:40:15 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 7 13:40:15 2015 +0200

tests: when test fails collect more info

In some case it might be worth to know some more surrouding info
when command has crashed.

So collect  tables and some udev db content in this case.
---
 test/lib/utils.sh |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 2f7dc65..401a862 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -130,6 +130,21 @@ STACKTRACE() {
 	test -z "$LVM_TEST_NODEBUG" -a -f debug.log && {
 		sed -e "s,^,## DEBUG: ,;s,$top_srcdir/\?,," < debug.log
 		test -e strace.log && sed -e "s,^,## STRACE: ,;s,$top_srcdir/\?,," < strace.log
+		echo "========= Info ==========="
+		dmsetup info -c | grep "$PREFIX"
+		echo "========= Active table ==========="
+		dmsetup table | grep "$PREFIX"
+		echo "======== Inactive table =========="
+		dmsetup table --inactive  | grep "$PREFIX"
+		echo "======== Status =========="
+		dmsetup status | grep "$PREFIX"
+		echo "======== Tree =========="
+		dmsetup ls --tree
+		echo "======== Recursive list of $DM_DEV_DIR =========="
+		ls -Rla "$DM_DEV_DIR"
+		for i in "/sys/block/dm-* /sys/block/loop*" ; do
+			udevadm info --export-db "$i" || true
+		done
 	}
 
 	test -f SKIP_THIS_TEST && exit 200


