From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Feb 2017 12:17:38 +0000 (UTC)
Subject: master - tests: drop /tmp polution
Message-ID: <20170206121738.E59DA60D2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=48abbdf4524f316aa93b2d8b857b59803095ace3
Commit:        48abbdf4524f316aa93b2d8b857b59803095ace3
Parent:        811d137d3f93da892365f9c9a4772033a891c687
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 6 09:48:19 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 6 11:43:07 2017 +0100

tests: drop /tmp polution

Drop forgotten extra metadata debug.
---
 test/shell/lvchange-cache-mode.sh |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvchange-cache-mode.sh b/test/shell/lvchange-cache-mode.sh
index 947034b..f7b1081 100644
--- a/test/shell/lvchange-cache-mode.sh
+++ b/test/shell/lvchange-cache-mode.sh
@@ -38,8 +38,6 @@ done
 
 lvs -o+cache_dirty_blocks,cache_read_hits,cache_read_misses,cache_write_hits,cache_write_misses $vg/$lv1
 
-vgcfgbackup -f /tmp/ooo $vg
-
 
 #
 # Drop later, code loading dm tables directly without lvm


