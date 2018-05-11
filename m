From: David Teigland <teigland@sourceware.org>
Date: Fri, 11 May 2018 15:38:43 -0400
Subject: master - devs: recognize md devices in subsystem check
Message-ID: <201805111938.w4BJch58002942@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b5d99146282d2747b96d37efb5d2a7dc02fa6327
Commit:        b5d99146282d2747b96d37efb5d2a7dc02fa6327
Parent:        ccab54677c9f92cf1bd11895251799c043a57602
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 11 14:00:19 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 11 14:00:19 2018 -0500

devs: recognize md devices in subsystem check

If md components appear as duplicate PVs, let the
existing subsystem check recognize the md device.
---
 lib/device/dev-type.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 8d4a403..af4b407 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -215,6 +215,9 @@ int dev_subsystem_part_major(struct dev_types *dt, struct device *dev)
 	if (MAJOR(dev->dev) == dt->device_mapper_major)
 		return 1;
 
+	if (MAJOR(dev->dev) == dt->md_major)
+		return 1;
+
 	if (MAJOR(dev->dev) == dt->drbd_major)
 		return 1;
 


