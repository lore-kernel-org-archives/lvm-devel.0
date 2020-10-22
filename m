From: David Teigland <teigland@sourceware.org>
Date: Thu, 22 Oct 2020 20:43:20 +0000 (GMT)
Subject: master - get dev size when setting pv device
Message-ID: <20201022204320.4DE00385783D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6226512ad2d6fd30a4b55da6a4d4c370fa7fad09
Commit:        6226512ad2d6fd30a4b55da6a4d4c370fa7fad09
Parent:        f3b723cd8d7b0ac3c7580ab6861666178bfba34f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 21 16:21:50 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 22 13:19:17 2020 -0500

get dev size when setting pv device

In some cases the dev size may not have been read yet
in set_pv_devices().  In this case get the dev size
before comparing the dev size with the pv size.
---
 lib/metadata/metadata.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5639377e5..d04b8d8ba 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3578,13 +3578,17 @@ static void _set_pv_device(struct format_instance *fid,
 	 * full a md check in label scan
 	 */
 	if (dev && cmd && cmd->md_component_detection && !cmd->use_full_md_check) {
+		uint64_t devsize = dev->size;
+
+		if (!devsize && !dev_get_size(dev, &devsize))
+			log_debug("No size for %s when setting PV dev.", dev_name(dev));
 
 		/* PV larger than dev not common, check for md component */
-		if (pv->size > dev->size)
+		else if (pv->size > devsize)
 			do_check = 1;
 
 		/* dev larger than PV can be common, limit check to auto mode */
-		else if ((pv->size < dev->size) && !strcmp(cmd->md_component_checks, "auto"))
+		else if ((pv->size < devsize) && !strcmp(cmd->md_component_checks, "auto"))
 			do_check = 1;
 
 		if (do_check && dev_is_md_component(dev, NULL, 1)) {


