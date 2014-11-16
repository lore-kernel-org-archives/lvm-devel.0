From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 16 Nov 2014 23:45:18 +0000 (UTC)
Subject: master - tests: skip another older kernel from raid456
Message-ID: <20141116234518.4745960EBF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=776934aa0811727405434698ab25b2c1e7722fa6
Commit:        776934aa0811727405434698ab25b2c1e7722fa6
Parent:        b622a7fe3ffa89e763577c3176a2cc2f1b1e2cdd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 17 00:32:49 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 17 00:32:49 2014 +0100

tests: skip another older kernel from raid456

---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index dcc86ed..1c168f0 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -733,7 +733,7 @@ raid456_replace_works() {
 	  3.9.*.fc19.i686*|3.9.*.fc19.x86_64) return 1 ;;
 	  3.1[0123].*.fc18.i686*|3.1[0123].*.fc18.x86_64) return 1 ;;
 	  3.1[01234].*.fc19.i686*|3.1[01234].*.fc19.x86_64) return 1 ;;
-	  3.13.*.fc20.i686*|3.13.*.fc20.x86_64) return 1 ;;
+	  3.1[123].*.fc20.i686*|3.1[123].*.fc20.x86_64) return 1 ;;
 	  3.14.*.fc21.i686*|3.14.*.fc21.x86_64) return 1 ;;
 	  3.15.*rc6*.fc21.i686*|3.15.*rc6*.fc21.x86_64) return 1 ;;
 	  3.16.*rc4*.fc21.i686*|3.16.*rc4*.fc21.x86_64) return 1 ;;


