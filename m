From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  1 May 2015 13:08:42 +0000 (UTC)
Subject: master - tests: run api tests from startup dir
Message-ID: <20150501130842.4E5CC60FC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4ce5b5fdf3e2758adf7e1313c98381071de85056
Commit:        4ce5b5fdf3e2758adf7e1313c98381071de85056
Parent:        a3473e60db68a4d122f68dd66625ee35ac1021be
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 1 15:01:33 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 1 15:07:59 2015 +0200

tests: run api tests from startup dir

---
 test/lib/aux.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 329c086..ae15235 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -870,8 +870,8 @@ prepare_profiles() {
 }
 
 apitest() {
-	test -x "api/$1.t" || skip
-	"api/$1.t" "${@:2}" && rm -f debug.log strace.log
+	test -x "$TESTOLDPWD/api/$1.t" || skip
+	"$TESTOLDPWD/api/$1.t" "${@:2}" && rm -f debug.log strace.log
 }
 
 mirror_recovery_works() {


