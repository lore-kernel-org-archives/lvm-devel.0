From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 21 May 2014 22:56:07 +0000 (UTC)
Subject: master - tests: more vgcfgrestore testing
Message-ID: <20140521225607.D957460F34@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=79f466524377f08ff4a736f159eac44f9923f4f1
Commit:        79f466524377f08ff4a736f159eac44f9923f4f1
Parent:        a4ac21aded0eec0e93ce0026cb77cd377d8713ef
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 21 23:12:00 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 21 23:14:41 2014 +0200

tests: more vgcfgrestore testing

Check '-l' and archiving.
---
 test/shell/vgcfgbackup-usage.sh |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/test/shell/vgcfgbackup-usage.sh b/test/shell/vgcfgbackup-usage.sh
index 193bb9d..bc09b5b 100644
--- a/test/shell/vgcfgbackup-usage.sh
+++ b/test/shell/vgcfgbackup-usage.sh
@@ -31,12 +31,22 @@ vgcfgbackup
 test -e etc/backup/$vg1
 test -e etc/backup/$vg2
 
+aux lvmconf "backup/archive = 1"
+
 vgcfgbackup -f "bak-%s" >out
 grep "Volume group \"$vg1\" successfully backed up." out
 grep "Volume group \"$vg2\" successfully backed up." out
 # increase seqno
 lvcreate -an -Zn -l1 $vg1
-vgcfgrestore -f "bak-$vg1" $vg1
+
+invalid vgcfgrestore -f "bak-$vg1" $vg1-inv at lid
+invalid vgcfgrestore -f "bak-$vg1" $vg1 $vg2
+
+vgcfgrestore -l $vg1 | tee out
+test $(grep Description out | wc -l) -eq 2
+
+vgcfgrestore -l -f "bak-$vg1" $vg1
+
 vgremove -ff $vg1 $vg2
 
 # vgcfgbackup correctly stores metadata with missing PVs


