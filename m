From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  6 Mar 2015 13:31:46 +0000 (UTC)
Subject: master - tests: slightly more efficient vgcreate
Message-ID: <20150306133146.6EC58600E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=85ef614b37bafd3c91c9fb6e6cfb6c40d6f80f99
Commit:        85ef614b37bafd3c91c9fb6e6cfb6c40d6f80f99
Parent:        04101bc4307e14f71f6ca3a1d253761f82e6a76e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 6 13:29:35 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 6 14:05:06 2015 +0100

tests: slightly more efficient vgcreate

With larger set of devices it's faster to directly call
vgcreate on empty set of devices then going though separate
pvcreate call first.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index d3a3382..339da31 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -576,7 +576,7 @@ prepare_pvs() {
 prepare_vg() {
 	teardown_devs
 
-	prepare_pvs "$@"
+	prepare_devs "$@"
 	vgcreate -s 512K $vg "${DEVICES[@]}"
 }
 


