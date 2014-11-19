From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 19 Nov 2014 22:25:25 +0000 (UTC)
Subject: master - tests: prepare control node before clvmd
Message-ID: <20141119222525.3CD1460392@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c75548300d63452b4fa615d71cb40cb10382aa33
Commit:        c75548300d63452b4fa615d71cb40cb10382aa33
Parent:        d7985ebead2a69f8139bf4ade0747b2a96f784c4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 19 23:22:52 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 19 23:22:52 2014 +0100

tests: prepare control node before clvmd

Make sure there is 'control' node before clvmd is started.
Somehow  'clvmd' is not allowed by selinux to create one.

TODO: Check is selinux policy is right here...
---
 test/lib/aux.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 58b71c6..2fef207 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -35,6 +35,7 @@ prepare_clvmd() {
 	# lvs is executed from clvmd - use our version
 	export LVM_BINARY=$(which lvm)
 
+	test -e "$DM_DEV_DIR/control" || dmsetup table # create control node
 	# skip if singlenode is not compiled in
 	(clvmd --help 2>&1 | grep "Available cluster managers" | grep "singlenode") || skip
 


