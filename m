From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Feb 2015 14:42:18 +0000 (UTC)
Subject: master - tests: BACKING_DEV
Message-ID: <20150212144218.204596010E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d303d9973f2a60db3c58b831193686fdb467e4f4
Commit:        d303d9973f2a60db3c58b831193686fdb467e4f4
Parent:        4b7097b96c94e115581e77588fe1591dae1e035f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 12 13:30:39 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 12 15:40:52 2015 +0100

tests: BACKING_DEV

Reset BACKING_DEV when it's same as LOOP.
Reset only 64K - so just eats a bit less space from underlaying loop
devices...
---
 test/lib/aux.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 9241fba..f33b62e 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -193,6 +193,7 @@ teardown_devs() {
 		test ! -f LOOPFILE || rm -f $(< LOOPFILE)
 	fi
 	rm -f DEVICES # devs is set in prepare_devs()
+	not diff LOOP BACKING_DEV || rm -f BACKING_DEV
 	rm -f LOOP
 
 	# Attempt to remove any loop devices that failed to get torn down if earlier tests aborted
@@ -392,7 +393,7 @@ prepare_devs() {
 
 	# non-ephemeral devices need to be cleared between tests
 	test -f LOOP || for d in ${DEVICES[@]}; do
-		dd if=/dev/zero of=$d bs=1M count=1
+		dd if=/dev/zero of=$d bs=64K count=1
 	done
 
 	#for i in `seq 1 $n`; do


