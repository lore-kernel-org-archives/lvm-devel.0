From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 15:24:35 +0000 (UTC)
Subject: master - format-text: Fix _raw_read_mda_header (missing close, open r/o).
Message-ID: <20140228152435.472D760EFA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3e5bec37e9cec455f20656858ba510b69010676d
Commit:        3e5bec37e9cec455f20656858ba510b69010676d
Parent:        c69d37d1260aac04b8964ca92af489a2de0e9d77
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Fri Feb 28 16:21:09 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 16:21:09 2014 +0100

format-text: Fix _raw_read_mda_header (missing close, open r/o).

---
 lib/format_text/format-text.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 0d6483a..e0b2786 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -318,12 +318,15 @@ static void _xlate_mdah(struct mda_header *mdah)
 
 static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev_area)
 {
-	if (!dev_open(dev_area->dev))
+	if (!dev_open_readonly(dev_area->dev))
 		return_0;
 
 	if (!dev_read(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, mdah))
 		return_0;
 
+	if (!dev_close(dev_area->dev))
+		return_0;
+
 	if (mdah->checksum_xl != xlate32(calc_crc(INITIAL_CRC, (uint8_t *)mdah->magic,
 						  MDA_HEADER_SIZE -
 						  sizeof(mdah->checksum_xl)))) {


