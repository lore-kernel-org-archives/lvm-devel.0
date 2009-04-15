From: Milan Broz <mbroz@redhat.com>
Date: Wed, 15 Apr 2009 18:35:01 +0200
Subject: [PATCH] add MMC block device type into filters
Message-ID: <49E60CB5.8050209@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add mmc (dev/mmcblk*) block device type to filters.

(tested with SD card)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/filters/filter.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/filters/filter.c b/lib/filters/filter.c
index 7b343fe..bc07cb6 100644
--- a/lib/filters/filter.c
+++ b/lib/filters/filter.c
@@ -78,6 +78,7 @@ static const device_info_t device_info[] = {
 	{"vdisk", 8},		/* SUN's LDOM virtual block device */
 	{"ps3disk", 16},	/* PlayStation 3 internal disk */
 	{"virtblk", 8},		/* VirtIO disk */
+	{"mmc", 16},		/* MMC block device */
 	{NULL, 0}
 };
 



