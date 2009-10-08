From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 8 Oct 2009 16:19:37 -0500
Subject: [PATCH 8 of 10] LVM: add logic to allow mirrored log
Message-ID: <200910082119.n98LJbrt014727@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-add-logic-to-allow-mirrored-log.patch

Insert the couple of lines that adds the logic necessary to
create the mirrored/redundant log.

RFC: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -1330,7 +1330,7 @@ static struct logical_volume *_set_up_mi
 						 struct alloc_handle *ah,
 						 struct logical_volume *lv,
 						 uint32_t log_count,
-						 uint32_t region_size __attribute((unused)),
+						 uint32_t region_size,
 						 alloc_policy_t alloc,
 						 int in_sync)
 {
@@ -1374,6 +1374,12 @@ static struct logical_volume *_set_up_mi
 		return NULL;
 	}
 
+	if ((log_count > 1) &&
+	    !_form_mirror(cmd, ah, log_lv, log_count-1, region_size, 1)) {
+		log_error("Failed to form mirrored log.");
+		return NULL;
+	}
+
 	if (!_init_mirror_log(cmd, log_lv, in_sync, &lv->tags, 1)) {
 		log_error("Failed to create mirror log.");
 		return NULL;


