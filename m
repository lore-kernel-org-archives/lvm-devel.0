From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 22 Jul 2014 22:30:05 +0000 (UTC)
Subject: master - tests: still unusable kernel
Message-ID: <20140722223005.BAC3A60E3D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8d63d94d853b9675f9d3a86de8b34c68db5d5226
Commit:        8d63d94d853b9675f9d3a86de8b34c68db5d5226
Parent:        22be7c441784fd89cf76cb6ed56fd50da126864d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 23 00:29:32 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 23 00:29:32 2014 +0200

tests: still unusable kernel

---
 test/lib/aux.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 7b96ad4..dcc86ed 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -736,6 +736,7 @@ raid456_replace_works() {
 	  3.13.*.fc20.i686*|3.13.*.fc20.x86_64) return 1 ;;
 	  3.14.*.fc21.i686*|3.14.*.fc21.x86_64) return 1 ;;
 	  3.15.*rc6*.fc21.i686*|3.15.*rc6*.fc21.x86_64) return 1 ;;
+	  3.16.*rc4*.fc21.i686*|3.16.*rc4*.fc21.x86_64) return 1 ;;
 	esac
 }
 


