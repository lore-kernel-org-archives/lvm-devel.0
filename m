From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 10 Jul 2022 23:22:20 +0000 (GMT)
Subject: main - vdo: add reformating to extent size aligned virtual size
Message-ID: <20220710232220.A5204385737B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a477490e812639fed3be495f215fcf1a7b65b7ee
Commit:        a477490e812639fed3be495f215fcf1a7b65b7ee
Parent:        ebad057579aeff0980a1b8af7eaacd56e62ed0c9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jul 9 00:42:01 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 11 01:18:24 2022 +0200

vdo: add reformating to extent size aligned virtual size

Newer VDO kernel target require to have matching virtual size - this
however cause incompatiblity when lvcreate is let to format VDO data
device and read the usable size from vdoformat.
Altough this is a kernel regression and will likely get fixed,
lvm2 can actually reformat VDO device to use properly aligned VDO LV
size to make this problem disappear.
---
 lib/metadata/vdo_manip.c | 22 +++++++++++++++++++---
 1 file changed, 19 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index b83bff391..a7de55d36 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -227,10 +227,11 @@ static int _format_vdo_pool_data_lv(struct logical_volume *data_lv,
 				    const struct dm_vdo_target_params *vtp,
 				    uint64_t *logical_size)
 {
-	char *dpath;
+	char *dpath, *c;
 	const struct dm_config_node *cn;
 	const struct dm_config_value *cv;
 	struct pipe_data pdata;
+	uint64_t logical_size_aligned = 1;
 	FILE *f;
 	uint64_t lb;
 	unsigned slabbits;
@@ -247,7 +248,9 @@ static int _format_vdo_pool_data_lv(struct logical_volume *data_lv,
 		return 0;
 	}
 
+reformat:
 	if (*logical_size) {
+		logical_size_aligned = 0;
 		if (dm_snprintf(buf_args[args], sizeof(buf_args[0]), "--logical-size=" FMTu64 "K",
 			       (*logical_size / 2)) < 0)
 			return_0;
@@ -332,8 +335,8 @@ static int _format_vdo_pool_data_lv(struct logical_volume *data_lv,
 				log_verbose("Available VDO logical blocks " FMTu64 " (%s).",
 					    lb, display_size(data_lv->vg->cmd, *logical_size));
 			}
-		if ((dpath = strchr(buf, '\n')))
-			*dpath = 0; /* cut last '\n' away */
+		if ((c = strchr(buf, '\n')))
+			*c = 0; /* cut last '\n' away */
 		if (buf[0])
 			log_print("  %s", buf); /* Print vdo_format messages */
 	}
@@ -348,6 +351,19 @@ static int _format_vdo_pool_data_lv(struct logical_volume *data_lv,
 		return 0;
 	}
 
+	if (logical_size_aligned) {
+		// align obtained size to extent size
+		logical_size_aligned = *logical_size / data_lv->vg->extent_size * data_lv->vg->extent_size;
+		if (*logical_size != logical_size_aligned) {
+			*logical_size = logical_size_aligned;
+			argv[1] = (char*) "--force";
+			args = 2;
+			log_verbose("Reformating VDO to align virtual size %s by extent size.",
+				    display_size(data_lv->vg->cmd, *logical_size));
+			goto reformat;
+		}
+	}
+
 	return 1;
 }
 

