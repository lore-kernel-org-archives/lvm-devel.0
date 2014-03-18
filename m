From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Mar 2014 09:31:56 +0000 (UTC)
Subject: master - tests: more fedora kernels unusable for testing raid456
Message-ID: <20140318093156.7DA4260DDE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=81166a84be44409ab326eb1c4760cb32a9aee0fe
Commit:        81166a84be44409ab326eb1c4760cb32a9aee0fe
Parent:        599a05f658326e8b683923e3255b3e05ccd54bb3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 17 18:38:59 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 18 10:28:08 2014 +0100

tests: more fedora kernels unusable for testing raid456

---
 test/lib/aux.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 63896d1..42ac0a5 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -682,6 +682,8 @@ raid456_replace_works() {
 # so we need to put here exlusion for kernes which do trace SLUB
 #
 	case $(uname -r) in
+	  3.6.*.fc18.i686*|3.6.*.fc18.x86_64) return 1 ;;
+	  3.9.*.fc19.i686*|3.9.*.fc19.x86_64) return 1 ;;
 	  3.1[0123].*.fc18.i686*|3.1[0123].*.fc18.x86_64) return 1 ;;
 	  3.1[0123].*.fc19.i686*|3.1[0123].*.fc19.x86_64) return 1 ;;
 	  3.13.*.fc20.i686*|3.13.*.fc20.x86_64) return 1 ;;


