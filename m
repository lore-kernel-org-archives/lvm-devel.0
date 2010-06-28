From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:36:38 -0000
Subject: LVM2 lib/config/defaults.h lib/metadata/metada ...
Message-ID: <20100628203638.17532.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:36:37

Modified files:
	lib/config     : defaults.h 
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : toollib.c 

Log message:
	Add mda_copies to VG structures and initialization.
	
	Add a field to struct volume_group to later implement metadata
	balancing:
	- mda_copies: target # of non-ignored mdas in the VG; default 0 (do
	not control pv 'ignore mdas' bit.
	
	This patch just adds the parameter to the structures with the default
	values but does not modify any commands.  Should be no functional change.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.155&r2=1.156
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.357&r2=1.358
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.202&r2=1.203

--- LVM2/lib/config/defaults.h	2010/05/20 13:47:21	1.60
+++ LVM2/lib/config/defaults.h	2010/06/28 20:36:37	1.61
@@ -61,6 +61,7 @@
 #define DEFAULT_STRIPESIZE 64	/* KB */
 #define DEFAULT_PVMETADATASIZE 255
 #define DEFAULT_PVMETADATACOPIES 1
+#define DEFAULT_VGMETADATACOPIES 0
 #define DEFAULT_LABELSECTOR UINT64_C(1)
 #define DEFAULT_READ_AHEAD "auto"
 #define DEFAULT_UDEV_RULES 1
--- LVM2/lib/metadata/metadata-exported.h	2010/06/28 20:33:44	1.155
+++ LVM2/lib/metadata/metadata-exported.h	2010/06/28 20:36:37	1.156
@@ -287,6 +287,7 @@
 	 * 0 for success else appropriate FAILURE_* bits set.
 	 */
 	uint32_t read_status;
+	uint32_t mda_copies; /* target number of mdas for this VG */
 };
 
 /* There will be one area for each stripe */
@@ -896,6 +897,7 @@
 	size_t max_lv;
 	alloc_policy_t alloc;
 	int clustered; /* FIXME: put this into a 'status' variable instead? */
+	uint32_t metadata_copies;
 };
 
 int vgcreate_params_validate(struct cmd_context *cmd,
--- LVM2/lib/metadata/metadata.c	2010/06/28 20:35:49	1.357
+++ LVM2/lib/metadata/metadata.c	2010/06/28 20:36:37	1.358
@@ -910,6 +910,7 @@
 	vg->max_pv = DEFAULT_MAX_PV;
 
 	vg->alloc = DEFAULT_ALLOC_POLICY;
+	vg->mda_copies = DEFAULT_VGMETADATACOPIES;
 
 	vg->pv_count = 0;
 	dm_list_init(&vg->pvs);
--- LVM2/tools/toollib.c	2010/06/03 12:45:09	1.202
+++ LVM2/tools/toollib.c	2010/06/28 20:36:37	1.203
@@ -1187,6 +1187,7 @@
 		vp_def->max_lv = vg->max_lv;
 		vp_def->alloc = vg->alloc;
 		vp_def->clustered = vg_is_clustered(vg);
+		vp_def->metadata_copies = vg->mda_copies;
 	} else {
 		vp_def->vg_name = NULL;
 		vp_def->extent_size = DEFAULT_EXTENT_SIZE * 2;
@@ -1194,6 +1195,7 @@
 		vp_def->max_lv = DEFAULT_MAX_LV;
 		vp_def->alloc = DEFAULT_ALLOC_POLICY;
 		vp_def->clustered = DEFAULT_CLUSTERED;
+		vp_def->metadata_copies = DEFAULT_VGMETADATACOPIES;
 	}
 }
 


