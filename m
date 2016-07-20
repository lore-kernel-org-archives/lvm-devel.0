From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 20 Jul 2016 11:49:10 +0000 (UTC)
Subject: master - scripts: blkdeactivate: fix typo for DEV_DIR when executing blkdeactivate -m disablequeueing
Message-ID: <20160720114910.48B2B607B9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=19e652b182099ca06c678394eccd1988967dacf9
Commit:        19e652b182099ca06c678394eccd1988967dacf9
Parent:        9d19c1075f0265aed7a1d1dab216e65cae6d460a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 20 13:48:59 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 20 13:48:59 2016 +0200

scripts: blkdeactivate: fix typo for DEV_DIR when executing blkdeactivate -m disablequeueing

---
 scripts/blkdeactivate.sh.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index de74756..50ea2d1 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -466,7 +466,7 @@ set_env() {
 	MPATHD_RUNNING=0
 	test $MPATHD_DO_DISABLEQUEUEING -eq 1 && {
 		if test -f $MPATHD; then
-			if eval $MPATHD show daemon $ERR | grep "running" >$DEVDIR/null; then
+			if eval $MPATHD show daemon $ERR | grep "running" >$DEV_DIR/null; then
 				MPATHD_RUNNING=1
 			fi
 		fi


