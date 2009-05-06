From: Milan Broz <mbroz@redhat.com>
Date: Wed, 06 May 2009 15:19:07 +0200
Subject: [PATCH v2] Fix PV datalign when for values starts prior to MDA area
In-Reply-To: <49FF4B4A.1080208@redhat.com>
References: <49FF4B4A.1080208@redhat.com>
Message-ID: <4A018E4B.3020702@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix PV datalign when for values starts prior to MDA area.

The dataalign value must always be aligned according
to MDA area.
The currect code checks if calculated value collides with
MDA area but not if the value is so small that it is
located before MDA starts.

Unfortunatelly there can be also MDA in the end of the device.

The patch adds simple check to avoid this miscalculation.
Patch expects that first MDA always starts on <= pagesize boundary
(this is true for all allowed label sector parameters).

(Similar patch was somehow lost during datalign patch review...)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/format_text/format-text.c |    4 +++-
 test/t-pvcreate-usage.sh      |    3 +++
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 5488d32..4181335 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1372,7 +1372,9 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 	dm_list_iterate_items(mda, &info->mdas) {
 		mdac = (struct mda_context *) mda->metadata_locn;
 		if (pv->dev == mdac->area.dev &&
-		    (mdac->area.start <= (pv->pe_start << SECTOR_SHIFT)) &&
+		    ((mdac->area.start <= (pv->pe_start << SECTOR_SHIFT)) ||
+		    (mdac->area.start <= lvm_getpagesize() &&
+		     pv->pe_start < (lvm_getpagesize() >> SECTOR_SHIFT))) &&
 		    (mdac->area.start + mdac->area.size >
 		     (pv->pe_start << SECTOR_SHIFT))) {
 			pv->pe_start = (mdac->area.start + mdac->area.size)
diff --git a/test/t-pvcreate-usage.sh b/test/t-pvcreate-usage.sh
index dc4537e..aa5877d 100755
--- a/test/t-pvcreate-usage.sh
+++ b/test/t-pvcreate-usage.sh
@@ -94,6 +94,9 @@ check_pv_field_ $dev1 pe_start 512.00K
 pvcreate --metadatasize 100k --dataalignment 100k $dev1
 check_pv_field_ $dev1 pe_start 200.00K
 
+pvcreate --metadatasize 128k --dataalignment 3.5k $dev1
+check_pv_field_ $dev1 pe_start 133.00K
+
 #COMM 'pv with LVM1 compatible data alignment can be convereted'
 #compatible == LVM1_PE_ALIGN == 64k
 pvcreate --dataalignment 256k $dev1



