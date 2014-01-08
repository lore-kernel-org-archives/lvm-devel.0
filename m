From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  8 Jan 2014 12:53:01 +0000 (UTC)
Subject: master - tests: use compiled lvm for clvmd executed lvs
Message-ID: <20140108125301.B440D6098F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2b7f7d0ab488f4f179100e91223788fe268299be
Commit:        2b7f7d0ab488f4f179100e91223788fe268299be
Parent:        5f246bf768ae194fa19e71e596f99ca02547c55c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 8 13:52:05 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 8 13:52:05 2014 +0100

tests: use compiled lvm for clvmd executed lvs

---
 test/lib/aux.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index ac6e111..2a882a2 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -31,6 +31,8 @@ prepare_clvmd() {
 
 	# skip if we don't have our own clvmd...
 	(which clvmd 2>/dev/null | grep "$abs_builddir") || skip
+	# lvs is executed from clvmd - use our version
+	export LVM_BINARY=$(which lvm)
 
 	# skip if we singlenode is not compiled in
 	(clvmd --help 2>&1 | grep "Available cluster managers" | grep "singlenode") || skip


