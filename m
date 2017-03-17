From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 17 Mar 2017 09:23:02 -0400
Subject: master - tests: raise min dm cache version
Message-ID: <201703171323.v2HDN2Qi012207@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=07ea9887d30ccdf71cc6363e45b2edf707066203
Commit:        07ea9887d30ccdf71cc6363e45b2edf707066203
Parent:        4a271e7ee720402d3045cd16b04fd7296131bdf5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 17 14:20:20 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 17 14:22:33 2017 +0100

tests: raise min dm cache version

Since we want to test different cache policies with profiles mq&smq
raise version to 1.8.

TODO: maybe split in more tests so older targets can test here as well.
N.B.: passthrough is also not supported with version 1.3
---
 test/shell/profiles-cache.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/profiles-cache.sh b/test/shell/profiles-cache.sh
index 8b27f20..f2acadb 100644
--- a/test/shell/profiles-cache.sh
+++ b/test/shell/profiles-cache.sh
@@ -17,7 +17,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux have_cache 1 3 0 || skip
+aux have_cache 1 8 0 || skip
 
 PDIR="$LVM_SYSTEM_DIR/profile"
 PFILE="cache-test"


