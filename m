From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 17 Oct 2013 15:01:09 +0000 (UTC)
Subject: master - tests: fix last commit
Message-ID: <20131017150109.567F56117C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d9e44112c53cad296858f5f796add99441a4b2ae
Commit:        d9e44112c53cad296858f5f796add99441a4b2ae
Parent:        66f4698a93c6cc7d0fb027c5e4209b1de6a880ef
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 17 16:59:30 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 17 16:59:30 2013 +0200

tests: fix last commit

It must not fail here during execution, so always check in a way
that '||' is used for call of settle.
---
 test/lib/utils.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 8311c4c..c3bd533 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -215,4 +215,4 @@ esac
 
 test -z "$PREFIX" || prepare_test_vars
 
-test -e /sbin/udevsettle && pidof udevd >/dev/null && /sbin/udevsettle
+test ! -e /sbin/udevsettle || if pidof udevd >/dev/null; then /sbin/udevsettle ; fi


