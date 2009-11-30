From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 30 Nov 2009 14:30:30 -0500
Subject: [PATCH] update support for cciss controller(s)
Message-ID: <20091130193030.GE9708@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The cciss driver calls register_blkdev() for each controller in the
system.  The first 8 cciss controllers are given a fixed major
(COMPAQ_CISS_MAJOR + i) and a name of: cciss%d

cciss controllers >8 get a dynamic major number.

Each controller supports a maximum of 16 partitions.

Update lvm's filtering to properly support the cciss controller (I left
"cciss" for compatibility's sake).

(This enables dracut to drop its, incorrect, "cciss0" 'types' entry).

diff --git a/lib/filters/filter.c b/lib/filters/filter.c
index 889b416..05da504 100644
--- a/lib/filters/filter.c
+++ b/lib/filters/filter.c
@@ -96,6 +96,14 @@ static const device_info_t device_info[] = {
 	{"nbd", 16},		/* Network Block Device */
 	{"ida", 16},		/* Compaq SMART2 */
 	{"cciss", 16},		/* Compaq CCISS array */
+	{"cciss0", 16},		/* Compaq CCISS array */
+	{"cciss1", 16},		/* Compaq CCISS array */
+	{"cciss2", 16},		/* Compaq CCISS array */
+	{"cciss3", 16},		/* Compaq CCISS array */
+	{"cciss4", 16},		/* Compaq CCISS array */
+	{"cciss5", 16},		/* Compaq CCISS array */
+	{"cciss6", 16},		/* Compaq CCISS array */
+	{"cciss7", 16},		/* Compaq CCISS array */
 	{"ubd", 16},		/* User-mode virtual block device */
 	{"ataraid", 16},	/* ATA Raid */
 	{"drbd", 16},		/* Distributed Replicated Block Device */


