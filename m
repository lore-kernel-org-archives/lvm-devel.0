From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 29 Sep 2020 08:45:29 +0000 (GMT)
Subject: master - tests: thin-flags
Message-ID: <20200929084529.C13E13861812@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=af8044da3ab6891495f4d96b51a52bc4ae457ffb
Commit:        af8044da3ab6891495f4d96b51a52bc4ae457ffb
Parent:        6728788bf5b7327a167675e99a1e00c168c6c563
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 27 01:24:17 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 29 10:43:56 2020 +0200

tests: thin-flags

---
 test/shell/thin-flags.sh | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/test/shell/thin-flags.sh b/test/shell/thin-flags.sh
index 91bcad12e..78a4b2cd7 100644
--- a/test/shell/thin-flags.sh
+++ b/test/shell/thin-flags.sh
@@ -92,6 +92,9 @@ check lv_attr_bit health $vg/pool "M"
 check lv_field $vg/pool lv_health_status "metadata_read_only"
 check lv_attr_bit health $vg/$lv2 "-"
 
+not lvcreate -s $vg/$lv2
+not lvcreate -V10 -n $lv3 $vg/pool
+
 lvs -ao+seg_pe_ranges $vg
 
 # needs_check needs newer version


