From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 28 Apr 2015 09:36:42 +0000 (UTC)
Subject: master - tests: always zero disk header
Message-ID: <20150428093642.79A9961086@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3fbb7b6e35b12c36838139eb365b526129b63baf
Commit:        3fbb7b6e35b12c36838139eb365b526129b63baf
Parent:        1bb5b498f01db75822a861046ca934f50447eb05
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 28 11:32:52 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 28 11:32:52 2015 +0200

tests: always zero disk header

It appear that older wipefs doesn't wipe partition table.
So ensure there is no partition on LVM_TEST_BACKING_DEVICE.
---
 test/lib/aux.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 1af43d0..0e59d6e 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -497,6 +497,8 @@ prepare_devs() {
 	# non-ephemeral devices need to be cleared between tests
 	test -f LOOP || for d in ${DEVICES[@]}; do
 		blkdiscard "$d" 2>/dev/null || true
+		# ensure disk header is always zeroed
+		dd if=/dev/zero of="$d" bs=4096 count=1
 		wipefs -a "$d" 2>/dev/null || dd if=/dev/zero of="$d" bs=64K count=1
 	done
 


