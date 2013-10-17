From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 17 Oct 2013 15:54:21 +0000 (UTC)
Subject: master - tests: older losetup allows only single device name
Message-ID: <20131017155421.0332460DFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7f4452a41e55a60678cadda99ae1a383a367a9e5
Commit:        7f4452a41e55a60678cadda99ae1a383a367a9e5
Parent:        d9e44112c53cad296858f5f796add99441a4b2ae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 17 17:52:42 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 17 17:52:42 2013 +0200

tests: older losetup allows only single device name

Stay compatible with only 1 arg for losetup -d
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index d27d263..f51fc0d 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -162,7 +162,7 @@ teardown_devs() {
 		local stray_loops=( $(losetup -a | grep "$COMMON_PREFIX" | cut -d: -f1) )
 		test ${#stray_loops[@]} -eq 0 || {
 			echo "Removing stray loop devices containing $COMMON_PREFIX: ${stray_loops[@]}"
-			losetup -d "${stray_loops[@]}"
+			for i in "${stray_loops[@]}" ; do losetup -d $i ; done
 		}
 	}
 }


