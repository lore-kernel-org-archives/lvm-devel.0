From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 3 Mar 2017 17:22:43 -0500
Subject: master - test: fix typo
Message-ID: <201703032222.v23MMhBM010447@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=17838e6439f7cabfa4609dbfb48197d5a33138f8
Commit:        17838e6439f7cabfa4609dbfb48197d5a33138f8
Parent:        11589891d7793e6ba1fc520ef9496bd35b497912
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 3 23:22:29 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 3 23:22:29 2017 +0100

test: fix typo

---
 test/shell/lvchange-raid1-writemostly.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvchange-raid1-writemostly.sh b/test/shell/lvchange-raid1-writemostly.sh
index edf11bd..1414398 100644
--- a/test/shell/lvchange-raid1-writemostly.sh
+++ b/test/shell/lvchange-raid1-writemostly.sh
@@ -25,7 +25,7 @@ do
 done
 
 #
-# Test writemostly prohibited on resyncrhonizing raid1
+# Test writemostly prohibited on resynchronizing raid1
 #
 
 # Create 4-way striped LV


