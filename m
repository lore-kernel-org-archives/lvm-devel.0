From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 28 Mar 2014 09:42:15 +0000 (UTC)
Subject: master - tests: check pvchange changes uuid
Message-ID: <20140328094215.27B5C613AA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2a79971004d4fb14b4483d7a87eca6eae4b8dd72
Commit:        2a79971004d4fb14b4483d7a87eca6eae4b8dd72
Parent:        09b180cfc252f1446fecc7b09672191043a7feb0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 28 10:37:33 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 28 10:41:59 2014 +0100

tests: check pvchange changes uuid

---
 test/shell/pvchange-usage.sh |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/test/shell/pvchange-usage.sh b/test/shell/pvchange-usage.sh
index e25230c..a6a03fa 100644
--- a/test/shell/pvchange-usage.sh
+++ b/test/shell/pvchange-usage.sh
@@ -46,12 +46,20 @@ pvcreate --metadatacopies 0 "$dev1"
 pvcreate --metadatacopies 2 "$dev2"
 vgcreate $vg1 "$dev1" "$dev2"
 
+# Checking for different UUID after pvchange
+UUID1=$(get pv_field "$dev1" uuid)
 pvchange -u "$dev1"
+test "$UUID1" != "$(get pv_field "$dev1" uuid)" || die "UUID has not changed!"
+
+UUID2=$(get pv_field "$dev2" uuid)
 pvchange -u "$dev2"
-UUID=$(get pv_field "$dev1" uuid)
+test "$UUID2" != "$(get pv_field "$dev2" uuid)" || die "UUID has not changed!"
+
+UUID1=$(get pv_field "$dev1" uuid)
+UUID2=$(get pv_field "$dev2" uuid)
 pvchange -u --all
-# Checking for different UUID after pvchange
-test "$UUID" != "$(get pv_field "$dev1" uuid)" || die "UUID has not changed!"
+test "$UUID1" != "$(get pv_field "$dev1" uuid)" || die "UUID has not changed!"
+test "$UUID2" != "$(get pv_field "$dev2" uuid)" || die "UUID has not changed!"
 check pvlv_counts $vg1 2 0 0
 
 # '-a' needs more params


