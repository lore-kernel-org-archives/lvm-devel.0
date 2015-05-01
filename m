From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  1 May 2015 13:08:38 +0000 (UTC)
Subject: master - tests: lower version of dm-delay
Message-ID: <20150501130838.0FF1660366@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dd4e6b4e7e1afc959f054732f5388b915f62ab18
Commit:        dd4e6b4e7e1afc959f054732f5388b915f62ab18
Parent:        16e8006eb05a3fd18d1efeb58f79ffbb41ba61e2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 30 22:21:18 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 1 15:07:58 2015 +0200

tests: lower version of dm-delay

Let's see what will break with lower version 1.1.

Also avoid repeated check of target version.
---
 test/lib/aux.sh |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 716d596..e6fd9fa 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -597,7 +597,10 @@ common_dev_() {
 # If the size is missing, the remaing portion of device is taken
 # i.e.  delay_dev "$dev1" 0 200 256:
 delay_dev() {
-	target_at_least dm-delay 1 2 0 || skip
+	if test ! -f HAVE_DM_DELAY ; then
+		target_at_least dm-delay 1 1 0 || skip
+	fi
+	touch HAVE_DM_DELAY
 	common_dev_ delay "$@"
 }
 


