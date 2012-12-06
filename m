From: Sebastian Ott <sebott@linux.vnet.ibm.com>
Date: Thu, 6 Dec 2012 12:42:13 +0100 (CET)
Subject: [PATCH] filters: add scm devices
Message-ID: <alpine.LFD.2.02.1212061239150.1655@c4eb>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Fix this:
pvcreate /dev/scma
  Device /dev/scma not found (or ignored by filtering).

Reported-by: Peter Oberparleiter <peter.oberparleiter@de.ibm.com>
Signed-off-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
---
 lib/filters/device-types.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/filters/device-types.h b/lib/filters/device-types.h
index aec4293..2e49f7f 100644
--- a/lib/filters/device-types.h
+++ b/lib/filters/device-types.h
@@ -58,5 +58,6 @@ static const device_info_t _device_info[] = {
 	{"mtip32xx", 16},	/* Micron PCIe SSDs */
 	{"vtms", 16},		/* Violin Memory */
 	{"skd", 16},		/* STEC */
+	{"scm", 8},		/* Storage Class Memory (IBM S/390) */
 	{"", 0}
 };
-- 
1.7.11.4


