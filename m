From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Feb 2015 14:54:37 +0000 (UTC)
Subject: master - tests: hide uninteresting output
Message-ID: <20150217145437.ECE8D610A4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=10b8d2a4ea538c21cf991fd608de47a9c18f85f4
Commit:        10b8d2a4ea538c21cf991fd608de47a9c18f85f4
Parent:        973afcbb2064ad5ca264d9262ed5fd0a7bdac50e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 17 15:53:24 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 17 15:54:21 2015 +0100

tests: hide uninteresting output

We don't care about diff output.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index f33b62e..d3a3382 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -193,7 +193,7 @@ teardown_devs() {
 		test ! -f LOOPFILE || rm -f $(< LOOPFILE)
 	fi
 	rm -f DEVICES # devs is set in prepare_devs()
-	not diff LOOP BACKING_DEV || rm -f BACKING_DEV
+	not diff LOOP BACKING_DEV >/dev/null 2>&1 || rm -f BACKING_DEV
 	rm -f LOOP
 
 	# Attempt to remove any loop devices that failed to get torn down if earlier tests aborted


