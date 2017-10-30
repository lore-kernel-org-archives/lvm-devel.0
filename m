From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 30 Oct 2017 12:29:12 -0400
Subject: master - tests: revert commit change
Message-ID: <201710301629.v9UGTCVl010061@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7e3be7d1ba4c6ae56dd80ec7ae098e9e451de775
Commit:        7e3be7d1ba4c6ae56dd80ec7ae098e9e451de775
Parent:        2b6391538c53e19a6fccdb4e3638ba9dd221819a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 30 17:26:42 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 30 17:27:29 2017 +0100

tests: revert commit change

Commit 04244107732feb5274bc24efed428a0d4ddae8f6 by mistake took also
this unwanted local modification of test - revert it.
---
 test/shell/metadata-balance.sh |   15 +++------------
 1 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/test/shell/metadata-balance.sh b/test/shell/metadata-balance.sh
index 1f22b24..fe94aed 100644
--- a/test/shell/metadata-balance.sh
+++ b/test/shell/metadata-balance.sh
@@ -189,8 +189,8 @@ done
 echo Test special situations, vgsplit, vgmerge, etc
 for mdacp in 1 2; do
 	pvcreate --metadatacopies $mdacp "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
-	vgcreate -cy --vgmetadatacopies 2 $vg1 "$dev1" "$dev2" "$dev3"
-	vgcreate -cy --vgmetadatacopies $(( mdacp * 1 )) $vg2 "$dev4" "$dev5"
+	vgcreate --vgmetadatacopies 2 $vg1 "$dev1" "$dev2" "$dev3"
+	vgcreate --vgmetadatacopies $(( mdacp * 1 )) $vg2 "$dev4" "$dev5"
 	echo vgsplit/vgmerge preserves value of metadata copies
 	check vg_field $vg1 vg_mda_copies 2
 	check vg_field $vg2 vg_mda_copies $(( mdacp * 1 ))
@@ -200,16 +200,7 @@ for mdacp in 1 2; do
 	check vg_field $vg1 vg_mda_copies 2
 	check vg_field $vg1 vg_mda_count $(( mdacp * 5 ))
 	echo vgsplit into new vg sets proper value of vgmetadatacopies
-#	echo y | pvchange -y --metadataignore n "$dev3" || true
-#	echo y | pvchange -y --metadataignore y "$dev4" || true
-#	echo y | pvchange -y --metadataignore n "$dev5" || true
-#	echo y | pvchange -y --metadataignore y "$dev1" || true
-#	echo y | pvchange -y --metadataignore y "$dev2" || true
-        pvs -o+pv_mda_size,pv_mda_count,pv_mda_used_count,pv_in_use
-        pvdisplay
-
-	#LVM_GDB=1
-        vgsplit --vgmetadatacopies $(( mdacp * 2 )) $vg1 $vg2 "$dev1" "$dev2"
+	vgsplit --vgmetadatacopies $(( mdacp * 2 )) $vg1 $vg2 "$dev1" "$dev2"
 	check vg_field $vg2 vg_mda_copies $(( mdacp * 2 ))
 	echo vgchange fails if given both vgmetadatacopies and metadatacopies
 	not vgchange --vgmetadatacopies 5 --metadatacopies 7 $vg2


