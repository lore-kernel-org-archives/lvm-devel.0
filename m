From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Feb 2021 16:44:45 +0000 (GMT)
Subject: main - fix check for md raid imsm signature on 4k devices
Message-ID: <20210222164445.E0AE93949D80@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=12667e9897ad54f5723463b4c864c8259ba0be2a
Commit:        12667e9897ad54f5723463b4c864c8259ba0be2a
Parent:        3cba07125457b82045f41bfafc67733c0dad89a2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 18 11:42:32 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 18 11:42:32 2021 -0600

fix check for md raid imsm signature on 4k devices

On devices with 4k logical block size, the imsm signature
is located 8k from the end of the device, not 1k as is
the case for devices with 512 LBS.
---
 lib/device/dev-md.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 36494b12b..3049b81b7 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -56,6 +56,16 @@ static int _dev_has_imsm_magic(struct device *dev, uint64_t devsize_sectors)
 {
 	char imsm_signature[IMSM_SIG_LEN];
 	uint64_t off = (devsize_sectors * 512) - 1024;
+	unsigned int physical_block_size = 0;
+	unsigned int logical_block_size = 0;
+
+	if (!dev_get_direct_block_sizes(dev, &physical_block_size, &logical_block_size))
+		return_0;
+
+	if (logical_block_size == 4096)
+		off = (devsize_sectors * 512) - 8192;
+	else
+		off = (devsize_sectors * 512) - 1024;
 
 	if (!dev_read_bytes(dev, off, IMSM_SIG_LEN, imsm_signature))
 		return_0;


