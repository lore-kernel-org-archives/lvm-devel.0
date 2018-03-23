From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Mar 2018 12:25:42 -0400
Subject: master - tests: handle setting better
Message-ID: <201803231625.w2NGPgFk031907@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fe69731d31648af24383515c1c3bc323551d75e5
Commit:        fe69731d31648af24383515c1c3bc323551d75e5
Parent:        30975a3328a0d101dda935644349dac58e2fb97f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 19 19:58:53 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 23 17:25:00 2018 +0100

tests: handle setting better

When using 'make check...  LVM_TEST_AUX_TRACE=0'  make it behaving
like other supported VARS in use so it's like disabled.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 9f8c8d7..a7ad60a 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1650,7 +1650,7 @@ kernel_at_least() {
 	version_at_least "$(uname -r)" "$@"
 }
 
-test -z "${LVM_TEST_AUX_TRACE-}" || set -x
+test "${LVM_TEST_AUX_TRACE-0}" = "0" || set -x
 
 test -f DEVICES && devs=$(< DEVICES)
 


