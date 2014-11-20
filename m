From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 20 Nov 2014 15:53:21 +0000 (UTC)
Subject: master - test: Also test repeated --cachesettings in lvchange-cache.
Message-ID: <20141120155321.D57616024E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=71271cf9053bd4fb6d6dbf1c4240fcb105165084
Commit:        71271cf9053bd4fb6d6dbf1c4240fcb105165084
Parent:        c75ae0846e4c1a74fbd44d85837e2b6dc50e9783
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Nov 20 12:35:51 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Nov 20 16:51:07 2014 +0100

test: Also test repeated --cachesettings in lvchange-cache.

---
 test/shell/lvchange-cache.sh |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvchange-cache.sh b/test/shell/lvchange-cache.sh
index 4845bba..87a217a 100644
--- a/test/shell/lvchange-cache.sh
+++ b/test/shell/lvchange-cache.sh
@@ -47,4 +47,14 @@ dmsetup status | grep $vg-corigin | grep 'migration_threshold 2048'
 dmsetup status | grep $vg-corigin | grep 'sequential_threshold 13'
 dmsetup status | grep $vg-corigin | grep 'random_threshold 4'
 
+lvchange --cachesettings migration_threshold=233 --cachesettings sequential_threshold=13 --cachesettings random_threshold=1 $vg/corigin
+dmsetup status | grep $vg-corigin | grep 'migration_threshold 233 '
+dmsetup status | grep $vg-corigin | grep 'sequential_threshold 13 '
+dmsetup status | grep $vg-corigin | grep 'random_threshold 1 '
+
+lvchange --cachesettings random_threshold=default --cachesettings migration_threshold=default $vg/corigin
+dmsetup status | grep $vg-corigin | grep 'migration_threshold 2048 '
+dmsetup status | grep $vg-corigin | grep 'sequential_threshold 13 '
+dmsetup status | grep $vg-corigin | grep 'random_threshold 4 '
+
 vgremove -f $vg


