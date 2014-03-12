From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Mar 2014 18:47:28 +0000 (UTC)
Subject: master - tests: another kernel with unusable kmem_check
Message-ID: <20140312184728.663FE61295@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b14ebb2f153408f3ea4e6a1ca16e1e63bdfefe7
Commit:        8b14ebb2f153408f3ea4e6a1ca16e1e63bdfefe7
Parent:        bf42119b22731c97e8169ee8526ff6bda4a3d7bf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 12 16:16:41 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 12 16:17:36 2014 +0100

tests: another kernel with unusable kmem_check

---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 53d0fc7..c3adb56 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -678,7 +678,7 @@ raid456_replace_works() {
 #
 	case $(uname -r) in
 	  3.10.11-200.fc19.i686|3.10.11-200.fc19.x86_64) return 1 ;;
-	  3.13.5-101.fc19.i686.PAE) return 1 ;;
+	  3.13.5-101.fc19.i686.PAE|3.13.6-200.fc20.x86_64) return 1 ;;
 	esac
 }
 


