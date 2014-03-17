From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Mar 2014 13:33:22 +0000 (UTC)
Subject: master - tests: skip more Fedora kernels for raid456
Message-ID: <20140317133322.6A05D60EAF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7d3fa6fc32c1922d621a7a87ab81c0dc08679b10
Commit:        7d3fa6fc32c1922d621a7a87ab81c0dc08679b10
Parent:        0fc17fe1ce02182e5c6f2e8abf4f22f8468e44f2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 16 23:46:43 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 17 14:31:44 2014 +0100

tests: skip more Fedora kernels for raid456

---
 test/lib/aux.sh |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index bd292bb..12e8e04 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -681,8 +681,9 @@ raid456_replace_works() {
 # so we need to put here exlusion for kernes which do trace SLUB
 #
 	case $(uname -r) in
-	  3.10.11-200.fc19.i686|3.10.11-200.fc19.x86_64) return 1 ;;
-	  3.13.5-101.fc19.i686.PAE|3.13.6-200.fc20.x86_64) return 1 ;;
+	  3.1[0123].*.fc18.i686*|3.1[0123].*.fc18.x86_64) return 1 ;;
+	  3.1[0123].*.fc19.i686*|3.1[0123].*.fc19.x86_64) return 1 ;;
+	  3.13.*.fc20.i686*|3.13.*.fc20.x86_64) return 1 ;;
 	esac
 }
 


