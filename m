From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Oct 2012 12:32:17 +0000 (UTC)
Subject: master - test: resync is for mirror devices
Message-ID: <20121015123217.6BE79129C@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d864c6eacd3e2f40034eb583cb2df9fa7c72efbe
Commit:        d864c6eacd3e2f40034eb583cb2df9fa7c72efbe
Parent:        457387718600579b862fe940c9a9daea3da59141
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 14:31:41 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 14:31:41 2012 +0200

test: resync is for mirror devices

---
 test/shell/covercmd.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index 12d9be1..b77d378 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -79,7 +79,7 @@ for i in dumpconfig formats segtypes; do
 done
 
 for i in pr "p rw" an ay "-monitor y" "-monitor n" \
-        -resync -refresh "-addtag MYTAG" "-deltag MYETAG"; do
+        -refresh "-addtag MYTAG" "-deltag MYETAG"; do
 	lvchange -$i $vg/$lv
 done
 


