From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:34:19 +0000 (UTC)
Subject: master - tests: enable raid test on 4.3
Message-ID: <20151022213419.5848460612@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2786cd27da3e7c6176940495ba57653ead7cfe08
Commit:        2786cd27da3e7c6176940495ba57653ead7cfe08
Parent:        1a2d0a0c729e80e4cd122532829f3a11e6566823
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 16:51:18 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:46:10 2015 +0200

tests: enable raid test on 4.3

With kernel -rc6 it's passing our raid tests again - so enable
it in tests.

Note: related only to Fedora rawhide kernels...
---
 test/lib/aux.sh |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 8a25d87..3f99357 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1112,9 +1112,8 @@ have_raid() {
 	# some kernels have broken mdraid bitmaps, don't use them!
 	# may oops kernel, we know for sure all FC24 are currently broken
 	# in general any 4.1, 4.2 is likely useless unless patched
-	# hopefully 4.3 will be patched
 	case "$(uname -r)" in
-	  4.[123].*fc24*) return 1 ;;
+	  4.[12].*fc24*) return 1 ;;
 	esac
 }
 


