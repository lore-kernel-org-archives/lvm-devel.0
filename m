From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Dec 2013 13:09:01 +0000 (UTC)
Subject: master - tests: skip pool-label test for lvmetad
Message-ID: <20131217130901.9E55D60FD7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fd73b2b7b92a2bb1d3ae3d6c4d2eb5eef78594c0
Commit:        fd73b2b7b92a2bb1d3ae3d6c4d2eb5eef78594c0
Parent:        a8b5dce997b26ff10892aab83646b65c1146f576
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 16 13:29:46 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 17 14:08:54 2013 +0100

tests: skip pool-label test for lvmetad

Unsupported by lvmetad.
---
 test/shell/pool-labels.sh |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/test/shell/pool-labels.sh b/test/shell/pool-labels.sh
index 9d3fa03..b5cbbdc 100644
--- a/test/shell/pool-labels.sh
+++ b/test/shell/pool-labels.sh
@@ -11,6 +11,9 @@
 
 . lib/test
 
+# lvmetad does not handle pool labels so skip test.
+test ! -e LOCAL_LVMETAD || skip
+
 env printf "" || skip # skip if printf is not available
 
 # create the old GFS pool labeled linear devices


