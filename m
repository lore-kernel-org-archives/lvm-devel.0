From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue,  3 Jul 2012 15:56:14 +0000 (UTC)
Subject: master - TEST (lvconvert-raid): localize a function variable
Message-ID: <20120703155614.67EAF1775@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7168880caa5f09da254e930313c2d59547643bb2
Commit:        7168880caa5f09da254e930313c2d59547643bb2
Parent:        149ab6921e9029e12899c280f290656b1b60742f
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Jun 25 22:25:46 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Jun 25 22:25:46 2012 -0500

TEST (lvconvert-raid): localize a function variable

Function was overwriting a global variable because it used a variable
of the same name without first declaring it with 'local'.
---
 test/shell/lvconvert-raid.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index e7df164..6c289a8 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -60,6 +60,7 @@ is_in_sync_() {
 
 # wait_for_sync <VG/LV>
 wait_for_sync_() {
+	local i
 	for i in {1..100} ; do
 		is_in_sync_ $1 && return
 		sleep 1


