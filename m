From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 18 Mar 2021 18:15:00 +0000 (GMT)
Subject: main - dev_manager: skip also zero targets
Message-ID: <20210318181500.115C33844031@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=adc238062d13949cbf3a0b20abf310ee3f132e7e
Commit:        adc238062d13949cbf3a0b20abf310ee3f132e7e
Parent:        a9b4acd511beb4d5ba8d0175ad1fb56927d92c03
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 18 17:17:21 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 18 18:34:57 2021 +0100

dev_manager: skip also zero targets

Devices made only from 'error' target cannot be used,
but if the device is also combined from 'zero' target
the same rule can be applied as such device cannot be used.
---
 lib/activate/dev_manager.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 98917dc38..172a6bab1 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -630,7 +630,7 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check, i
 	char *params, *vgname, *lvname, *layer;
 	char vg_name[NAME_LEN];
 	void *next = NULL;
-	int only_error_target = 1;
+	int only_error_or_zero_target = 1;
 	int r = 0;
 
 	if (!(dmt = _setup_task_run(DM_DEVICE_STATUS, &info, NULL, NULL, NULL,
@@ -766,13 +766,15 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check, i
 			goto out;
 		}
 
-		if (strcmp(target_type, TARGET_NAME_ERROR))
-			only_error_target = 0;
+		if (only_error_or_zero_target &&
+		    strcmp(target_type, TARGET_NAME_ERROR) &&
+		    strcmp(target_type, TARGET_NAME_ZERO))
+			only_error_or_zero_target = 0;
 	} while (next);
 
-	/* Skip devices consisting entirely of error targets. */
+	/* Skip devices consisting entirely of error or zero targets. */
 	/* FIXME Deal with device stacked above error targets? */
-	if (check.check_error_target && only_error_target) {
+	if (check.check_error_target && only_error_or_zero_target) {
 		log_debug_activation("%s: Error device %s not usable.",
 				     dev_name(dev), name);
 		goto out;


