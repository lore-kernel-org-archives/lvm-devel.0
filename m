From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 23 May 2014 21:38:34 +0000 (UTC)
Subject: master - tests: add unusable kernel for raid5 testing
Message-ID: <20140523213834.9AD9460303@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b7476e91ef4370746f85e009becb65ef891cc3d0
Commit:        b7476e91ef4370746f85e009becb65ef891cc3d0
Parent:        c5c3995ed587aee6aaa15ea69df81c69a5bfbcd8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 23 22:40:31 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 23 23:35:42 2014 +0200

tests: add unusable kernel for raid5 testing

---
 test/lib/aux.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 01bc1ea..07ba576 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -702,6 +702,7 @@ raid456_replace_works() {
 	  3.1[0123].*.fc19.i686*|3.1[0123].*.fc19.x86_64) return 1 ;;
 	  3.13.*.fc20.i686*|3.13.*.fc20.x86_64) return 1 ;;
 	  3.14.*.fc21.i686*|3.14.*.fc21.x86_64) return 1 ;;
+	  3.15.*rc6*.fc21.i686*|3.15.*rc6*.fc21.x86_64) return 1 ;;
 	esac
 }
 


