From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Mar 2014 23:06:35 +0000 (UTC)
Subject: master - tests: remove also 3.14 fc21 kernels
Message-ID: <20140325230635.8CDAF61055@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fb471a372dd8b5e750e8001304657eefa355ce6e
Commit:        fb471a372dd8b5e750e8001304657eefa355ce6e
Parent:        c13f5dbb2521901f723d4c40fd5992ee0b992d8d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 25 20:13:25 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 26 00:04:59 2014 +0100

tests: remove also 3.14 fc21 kernels

---
 test/lib/aux.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 502ed84..aa4c7a6 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -690,6 +690,7 @@ raid456_replace_works() {
 	  3.1[0123].*.fc18.i686*|3.1[0123].*.fc18.x86_64) return 1 ;;
 	  3.1[0123].*.fc19.i686*|3.1[0123].*.fc19.x86_64) return 1 ;;
 	  3.13.*.fc20.i686*|3.13.*.fc20.x86_64) return 1 ;;
+	  3.14.*.fc21.i686*|3.14.*.fc21.x86_64) return 1 ;;
 	esac
 }
 


