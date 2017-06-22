From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 22 Jun 2017 14:18:35 -0400
Subject: master - tests: check lvdisplay for cache works
Message-ID: <201706221818.v5MIIZiJ006641@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7d5afcc0cb968ed73a6c793fd98e8d377cafe473
Commit:        7d5afcc0cb968ed73a6c793fd98e8d377cafe473
Parent:        41c10034aa0db3c63f18ff78b64af3a799c154a1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 22 20:08:24 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 22 20:17:20 2017 +0200

tests: check lvdisplay for cache works

---
 test/shell/lvcreate-cache.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 410e105..f19965a 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -251,6 +251,8 @@ fail lvcreate --type cache-pool -l1 --chunksize 1G $vg/cpool3
 lvcreate --type cache-pool -L10 $vg/cpool4
 fail lvcreate -H -L10 --chunksize 16M $vg/cpool4
 
+lvdisplay --maps $vg
+
 lvremove -f $vg
 
 lvcreate --type cache-pool -L10 $vg/cpool


