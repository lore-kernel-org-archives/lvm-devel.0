From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 24 Nov 2017 10:11:33 -0500
Subject: master - tests: typo
Message-ID: <201711241511.vAOFBXme000787@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7eae2647c0ad4458b90b7bcc85e42668b9f49607
Commit:        7eae2647c0ad4458b90b7bcc85e42668b9f49607
Parent:        7bffbe0e2f7f43acf9cdb93f9d24cfb8638c7e7b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 21 15:34:02 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 24 16:09:59 2017 +0100

tests: typo

---
 test/shell/lvconvert-repair-cache.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-repair-cache.sh b/test/shell/lvconvert-repair-cache.sh
index 5470e3f..b7925e2 100644
--- a/test/shell/lvconvert-repair-cache.sh
+++ b/test/shell/lvconvert-repair-cache.sh
@@ -46,7 +46,7 @@ aux disable_dev "$dev1"
 
 #lvchange -an $vg
 
-# Check it is prompting fro confirmation
+# Check it is prompting for confirmation
 not lvconvert --uncache $vg/$lv1
 # --yes to drop when Check its prompting
 lvconvert --yes --uncache $vg/$lv1


