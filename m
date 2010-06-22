From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 22 Jun 2010 12:37:57 -0400
Subject: [PATCH] Add device name to output of error messages in raw_read_mda_header().
Message-ID: <1277224677-27844-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

It would be helpful if we had the device name when something like
a mda_header checksum error occurs.

Before:
./tools/lvm pvs -opv_name,vg_name,uuid,mda_count,pv_mda_count_ignored,vg_mda_count,vg_mda_count_ignored,vg_mda_copies
  Incorrect metadata area header checksum
  PV         VG      PV UUID                                #PMda #PMdaIgn #VMda #VMdaIgn #VMdaCps
  /dev/loop0 vgtest2 sVv26t-gjpb-Rcau-uBDO-Cx04-GbRR-6Ssq7e     2        0     4        0        4
  /dev/loop1 vgtest2 zXWStT-qE8F-mbkc-RfgH-aytv-mptF-Y5Ce09     2        0     4        0        4
  /dev/loop2         riCpK9-9G8r-LlIp-i2oh-mb3N-CUzk-u5YpuR     1        0     0        0        0
  /dev/loop3 vgtest  tQCUjm-rmyd-i92d-4eeE-UYBW-v1vQ-kRaA17     2        0     4        2        0
  /dev/loop4 vgtest  ZRvpeI-p8F1-ccVW-BBac-xhl1-aGXU-CbP0oo     2        2     4        2        0

After:
./tools/lvm pvs -opv_name,vg_name,uuid,mda_count,pv_mda_count_ignored,vg_mda_count,vg_mda_count_ignored,vg_mda_copies
  Incorrect metadata area header checksum on /dev/loop2
  PV         VG      PV UUID                                #PMda #PMdaIgn #VMda #VMdaIgn #VMdaCps
  /dev/loop0 vgtest2 sVv26t-gjpb-Rcau-uBDO-Cx04-GbRR-6Ssq7e     2        0     4        0        4
  /dev/loop1 vgtest2 zXWStT-qE8F-mbkc-RfgH-aytv-mptF-Y5Ce09     2        0     4        0        4
  /dev/loop2         riCpK9-9G8r-LlIp-i2oh-mb3N-CUzk-u5YpuR     1        0     0        0        0
  /dev/loop3 vgtest  tQCUjm-rmyd-i92d-4eeE-UYBW-v1vQ-kRaA17     2        0     4        2        0
  /dev/loop4 vgtest  ZRvpeI-p8F1-ccVW-BBac-xhl1-aGXU-CbP0oo     2        2     4        2        0

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_text/format-text.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 6e02f12..aa3404f 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -311,26 +311,28 @@ static struct mda_header *_raw_read_mda_header(const struct format_type *fmt,
 	if (mdah->checksum_xl != xlate32(calc_crc(INITIAL_CRC, mdah->magic,
 						  MDA_HEADER_SIZE -
 						  sizeof(mdah->checksum_xl)))) {
-		log_error("Incorrect metadata area header checksum");
+		log_error("Incorrect metadata area header checksum on %s",
+			  dev_name(dev_area->dev));
 		goto bad;
 	}
 
 	_xlate_mdah(mdah);
 
 	if (strncmp((char *)mdah->magic, FMTT_MAGIC, sizeof(mdah->magic))) {
-		log_error("Wrong magic number in metadata area header");
+		log_error("Wrong magic number in metadata area header on %s",
+			  dev_name(dev_area->dev));
 		goto bad;
 	}
 
 	if (mdah->version != FMTT_VERSION) {
-		log_error("Incompatible metadata area header version: %d",
-			  mdah->version);
+		log_error("Incompatible metadata area header version: %d on %s",
+			  dev_name(dev_area->dev), mdah->version);
 		goto bad;
 	}
 
 	if (mdah->start != dev_area->start) {
 		log_error("Incorrect start sector in metadata area header: %"
-			  PRIu64, mdah->start);
+			  PRIu64" on %s", mdah->start, dev_name(dev_area->dev));
 		goto bad;
 	}
 
-- 
1.6.0.6


