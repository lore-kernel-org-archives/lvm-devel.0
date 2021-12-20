From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Dec 2021 15:14:03 +0000 (GMT)
Subject: main - vdo: ensure VDO config is removed
Message-ID: <20211220151403.C9AA03858408@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=522561e64b5fe73cb9d01c2ee2d4b7624b0ddff4
Commit:        522561e64b5fe73cb9d01c2ee2d4b7624b0ddff4
Parent:        0f71183f9434d513733d38fb7f9619421d8afaf5
Author:        Andrew Walsh <awalsh@redhat.com>
AuthorDate:    Mon Nov 15 10:49:06 2021 -0500
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 20 16:13:28 2021 +0100

vdo: ensure VDO config is removed

Make sure to remove the VDO config after conversion
of LVM-backed VDO.

Addresses point 3 in rhbz#1987024#c5
---
 scripts/lvm_import_vdo.sh | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/scripts/lvm_import_vdo.sh b/scripts/lvm_import_vdo.sh
index 61a82e41e..d01766743 100755
--- a/scripts/lvm_import_vdo.sh
+++ b/scripts/lvm_import_vdo.sh
@@ -414,6 +414,12 @@ EOF
 	verbose "Converting to VDO pool."
 	dry "$LVM" lvconvert $YES $VERB $FORCE --config "$PARAMS" -Zn -V "${vdo_logicalSize}k" -n "$LVNAME" --type vdo-pool "$VGNAME/${LVNAME}_vpool"
 
+	# Note: that this is spelled OPPOSITE the other $IS_LV checks.
+	if [ "$IS_LV" = "1" ]; then
+		verbose "Removing now-unused VDO entry from VDO config."
+		dry "$VDO" remove $VDOCONF --force --verbose --name "$VDONAME"
+	fi
+
 	rm -fr "$TEMPDIR"
 }
 


