From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 19 Jun 2014 10:56:00 +0000 (UTC)
Subject: master - tests: remove dmeventd usage
Message-ID: <20140619105600.DA69E602F4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bc0a1ca83d6d89dd86d0d8e43239b97505e82e84
Commit:        bc0a1ca83d6d89dd86d0d8e43239b97505e82e84
Parent:        b193a3b09ffd28b7a170acc74095a05fa8fe2f8e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 19 12:48:21 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 19 12:48:21 2014 +0200

tests: remove dmeventd usage

This test is testing --use-policies on cmdline.
So monitoring must not be used.
---
 test/shell/lvextend-snapshot-policy.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvextend-snapshot-policy.sh b/test/shell/lvextend-snapshot-policy.sh
index 210e2fb..b0a611e 100644
--- a/test/shell/lvextend-snapshot-policy.sh
+++ b/test/shell/lvextend-snapshot-policy.sh
@@ -27,7 +27,7 @@ percent() {
 	get lv_field $vg/snap snap_percent | cut -d. -f1
 }
 
-aux prepare_dmeventd
+# no dmeventd running in this test, testing --use-policies
 aux prepare_vg 2
 
 lvcreate -aey -L24 -n base $vg


