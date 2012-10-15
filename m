From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Oct 2012 11:24:00 +0000 (UTC)
Subject: master - scripts: blk-availability - use the same name for lock file
Message-ID: <20121015112400.649D3226A@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c93659e0e0fac317f4fe35dc19ba86e5977721d7
Commit:        c93659e0e0fac317f4fe35dc19ba86e5977721d7
Parent:        4dace48f51dce7a7473934f7f7ff8d74e478cd8f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Oct 15 13:22:36 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Oct 15 13:22:36 2012 +0200

scripts: blk-availability - use the same name for lock file

---
 scripts/blk_availability_init_red_hat.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/blk_availability_init_red_hat.in b/scripts/blk_availability_init_red_hat.in
index b6c4a67..618f3d3 100644
--- a/scripts/blk_availability_init_red_hat.in
+++ b/scripts/blk_availability_init_red_hat.in
@@ -35,7 +35,7 @@ sbindir=@sbindir@
 script=blkdeactivate
 options="-u -l wholevg"
 
-LOCK_FILE="/var/lock/subsys/$script"
+LOCK_FILE="/var/lock/subsys/blk-availability"
 
 
 rtrn=1


