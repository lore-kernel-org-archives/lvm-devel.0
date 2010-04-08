From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 8 Apr 2010 15:18:35 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20100408151835.31677.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-04-08 15:18:35

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Check for duplicate paths (pvids) on the commandline of vgcreate.
	
	A user specifying duplicate paths on the cmdline of vgcreate will
	get a message similar to the following:
	vgcreate vgtest2 /dev/loop3 /dev/loop5
	Found duplicate PV jk1lXsKzwyOKlXq6bhaFFKMQQ06oPgu8: using /dev/loop5 not /dev/loop3
	Found duplicate PV jk1lXsKzwyOKlXq6bhaFFKMQQ06oPgu8: using /dev/loop3 not /dev/loop5
	Internal error: Duplicate PV id jk1lXs-Kzwy-OKlX-q6bh-aFFK-MQQ0-6oPgu8 detected for /dev/loop3 in vgtest2.
	
	This is caught by vg_validate(), but it would be good to find
	this condition earlier in the vgcreate code.  add_pv_to_vg()
	currently checks by pvname, but does not look for duplcate pvids.
	This patch adds the check for duplicate pvids and results in new
	error output as follows:
	vgcreate vgtest2 /dev/loop3 /dev/loop5
	Found duplicate PV jk1lXsKzwyOKlXq6bhaFFKMQQ06oPgu8: using /dev/loop5 not /dev/loop3
	Found duplicate PV jk1lXsKzwyOKlXq6bhaFFKMQQ06oPgu8: using /dev/loop3 not /dev/loop5
	Physical volume '/dev/loop5 (jk1lXs-Kzwy-OKlX-q6bh-aFFK-MQQ0-6oPgu8)' listed more than once.
	Unable to add physical volume '/dev/loop5' to volume group 'vgtest2'.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.331&r2=1.332

--- LVM2/lib/metadata/metadata.c	2010/04/06 14:04:57	1.331
+++ LVM2/lib/metadata/metadata.c	2010/04/08 15:18:35	1.332
@@ -52,6 +52,9 @@
 static struct pv_list *_find_pv_in_vg(const struct volume_group *vg,
 				      const char *pv_name);
 
+static struct pv_list *_find_pv_in_vg_by_uuid(const struct volume_group *vg,
+					      const struct id *id);
+
 static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
 				    uint64_t status);
 
@@ -160,6 +163,7 @@
 	struct pv_list *pvl;
 	struct format_instance *fid = vg->fid;
 	struct dm_pool *mem = vg->vgmem;
+	char uuid[64] __attribute((aligned(8)));
 
 	log_verbose("Adding physical volume '%s' to volume group '%s'",
 		    pv_name, vg->name);
@@ -211,9 +215,14 @@
 		return 0;
 	}
 
-	if (_find_pv_in_vg(vg, pv_name)) {
-		log_error("Physical volume '%s' listed more than once.",
-			  pv_name);
+	if (_find_pv_in_vg(vg, pv_name) ||
+	    _find_pv_in_vg_by_uuid(vg, &pv->id)) {
+		if (!id_write_format(&pv->id, uuid, sizeof(uuid))) {
+			stack;
+			uuid[0] = '\0';
+		}
+		log_error("Physical volume '%s (%s)' listed more than once.",
+			  pv_name, uuid);
 		return 0;
 	}
 


