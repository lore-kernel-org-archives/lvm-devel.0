From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:04 +0000 (UTC)
Subject: master - test: Re-try with loopback if a backing device is too small.
Message-ID: <20150205134304.867C760E22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7a0aa25c28ccb89834a83b06917be803713b4804
Commit:        7a0aa25c28ccb89834a83b06917be803713b4804
Parent:        f3cc6576ee065b02ff58974f0f0e8792dffbd824
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Sep 30 16:19:14 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:21 2015 +0100

test: Re-try with loopback if a backing device is too small.

---
 test/lib/aux.sh |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 84edb7d..32268a6 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -370,7 +370,13 @@ prepare_devs() {
 		DEVICES[$count]=$dev
 		count=$(( $count + 1 ))
 		echo 0 $size linear "$BACKING_DEV" $((($i-1)*$size)) > "$name.table"
-		dmsetup create -u "TEST-$name" "$name" "$name.table"
+		if not dmsetup create -u "TEST-$name" "$name" "$name.table" &&
+		   test -n "$LVM_TEST_BACKING_DEVICE";
+		then # maybe the backing device is too small for this test
+		    LVM_TEST_BACKING_DEVICE=
+		    prepare_devs "$@"
+		    return $?
+		fi
 	done
 	finish_udev_transaction
 


