From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Wed,  9 Mar 2016 10:10:30 +0000 (UTC)
Subject: master - test: Update kernels to skip thin-flags with
Message-ID: <20160309101030.DC29960D36@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2cf13b701aba8b9c23509c91d49dd7ba5b1f4273
Commit:        2cf13b701aba8b9c23509c91d49dd7ba5b1f4273
Parent:        6d19c14c28b24dded999d4bf50a4638581c649f5
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Mar 8 09:46:34 2016 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Mar 9 10:09:29 2016 +0100

test: Update kernels to skip thin-flags with

See ed5e5c38b5ac4b7c8cb7e809d9d35c72f087e29e
---
 test/lib/aux.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index e517bc0..5911eaf 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1153,6 +1153,8 @@ raid456_replace_works() {
 thin_pool_error_works_32() {
 	case "$(uname -r)" in
 	  2.6.32-618.*.i686) return 1 ;;
+	  2.6.32-623.*.i686) return 1 ;;
+	  2.6.32-573.1[28].1.el6.i686) return 1 ;;
 	esac
 }
 


