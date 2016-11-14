From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Nov 2016 11:57:25 +0000 (UTC)
Subject: master - tests: fix checking for pvmove LV
Message-ID: <20161114115725.F3D1060DA3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e7da8e7e1f27c2ee193a2dfc20819076c2bd19bf
Commit:        e7da8e7e1f27c2ee193a2dfc20819076c2bd19bf
Parent:        a7691cdebb6333b8f35d6a5a1a7d18aad6536c23
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 14 12:55:43 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 14 12:55:43 2016 +0100

tests: fix checking for pvmove LV

Use consitently egrep.

TODO: make probably aux func
---
 test/shell/pvmove-resume-2.sh        |    2 +-
 test/shell/pvmove-resume-multiseg.sh |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/pvmove-resume-2.sh b/test/shell/pvmove-resume-2.sh
index 3baa6df..29fd2a8 100644
--- a/test/shell/pvmove-resume-2.sh
+++ b/test/shell/pvmove-resume-2.sh
@@ -76,7 +76,7 @@ test_pvmove_resume() {
 	aux enable_dev "$dev2"
 
 	i=0
-	while get lv_field $vg name -a | grep "^pvmove"; do
+	while get lv_field $vg name -a | egrep "^\[?pvmove"; do
 		# wait for 30 secs at max
 		test $i -ge 300 && die "Pvmove is too slow or does not progress."
 		sleep .1
diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
index c22770f..a2fbf35 100644
--- a/test/shell/pvmove-resume-multiseg.sh
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -89,7 +89,7 @@ test_pvmove_resume() {
 	aux enable_dev "$dev5"
 
 	i=0
-	while get lv_field $vg name -a | grep "^\[?pvmove"; do
+	while get lv_field $vg name -a | egrep "^\[?pvmove"; do
 		# wait for 30 secs at max
 		test $i -ge 300 && die "Pvmove is too slow or does not progress."
 		sleep .1


