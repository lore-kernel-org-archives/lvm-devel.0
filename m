From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 19 Apr 2016 16:49:31 +0000 (UTC)
Subject: master - test: lvmetad-no-cluster
Message-ID: <20160419164931.545D26108B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c5cd5b4b696ae85727be8df1fa5b335134531cd6
Commit:        c5cd5b4b696ae85727be8df1fa5b335134531cd6
Parent:        a5722ed7e7b382f3bbb87c5e88c4a78e9ec4cf90
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 18 13:39:03 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 19 11:45:24 2016 -0500

test: lvmetad-no-cluster

Update warning message check
---
 test/shell/lvmetad-no-cluster.sh |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvmetad-no-cluster.sh b/test/shell/lvmetad-no-cluster.sh
index 7ac448f..d894114 100644
--- a/test/shell/lvmetad-no-cluster.sh
+++ b/test/shell/lvmetad-no-cluster.sh
@@ -17,8 +17,7 @@ SKIP_WITH_LVMPOLLD=1
 
 aux prepare_vg 2
 aux prepare_lvmetad
-vgs -vv 2> errs
-cat errs
-grep 'use_lvmetad' errs
+vgs 2>&1 | tee out
+grep "WARNING: Not using lvmetad because locking_type is 3" out
 
 vgremove -ff $vg


