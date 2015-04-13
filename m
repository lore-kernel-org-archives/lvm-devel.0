From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 13 Apr 2015 14:39:30 +0000 (UTC)
Subject: master - tests: hide unwanted output
Message-ID: <20150413143930.4E3A360F0C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f080ebc123a050eff1de3995d7da8c835c4dc6e7
Commit:        f080ebc123a050eff1de3995d7da8c835c4dc6e7
Parent:        391500643cdf7b43783212c87b6b46291e701afa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 13 14:19:54 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 13 16:38:31 2015 +0200

tests: hide unwanted output

---
 test/lib/aux.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index f471fa4..a5d620a 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -31,13 +31,13 @@ prepare_clvmd() {
 	fi
 
 	# skip if we don't have our own clvmd...
-	(which clvmd 2>/dev/null | grep "$abs_builddir") || skip
+	(which clvmd 2>/dev/null | grep -q "$abs_builddir") || skip
 	# lvs is executed from clvmd - use our version
 	export LVM_BINARY=$(which lvm)
 
-	test -e "$DM_DEV_DIR/control" || dmsetup table # create control node
+	test -e "$DM_DEV_DIR/control" || dmsetup table >/dev/null # create control node
 	# skip if singlenode is not compiled in
-	(clvmd --help 2>&1 | grep "Available cluster managers" | grep "singlenode") || skip
+	(clvmd --help 2>&1 | grep "Available cluster managers" | grep -q "singlenode") || skip
 
 #	lvmconf "activation/monitoring = 1"
 	local run_valgrind=


