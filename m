From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 01:53:31 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20090726015331.5730.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 01:53:30

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Allow pvcreate_single to be called with NULL for default pvcreate params.
	
	Passing NULL for pvcreate parameters gives you default parameters for
	pvcreate_single.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.262&r2=1.263

--- LVM2/lib/metadata/metadata.c	2009/07/26 01:53:09	1.262
+++ LVM2/lib/metadata/metadata.c	2009/07/26 01:53:30	1.263
@@ -1089,12 +1089,37 @@
 	return 1;
 }
 
+static void fill_default_pvcreate_params(struct pvcreate_params *pp)
+{
+	memset(pp, 0, sizeof(*pp));
+	pp->zero = 0;
+	pp->size = 0;
+	pp->data_alignment = UINT64_C(0);
+	pp->pvmetadatacopies = DEFAULT_PVMETADATACOPIES;
+	pp->pvmetadatasize = DEFAULT_PVMETADATASIZE;
+	pp->labelsector = DEFAULT_LABELSECTOR;
+	pp->idp = 0;
+	pp->pe_start = 0;
+	pp->extent_count = 0;
+	pp->extent_size = 0;
+	pp->restorefile = 0;
+	pp->force = PROMPT;
+	pp->yes = 0;
+}
+
 int pvcreate_single(struct cmd_context *cmd, const char *pv_name, void *handle)
 {
-	struct pvcreate_params *pp = (struct pvcreate_params *) handle;
+	struct pvcreate_params *pp;
 	void *pv;
 	struct device *dev;
 	struct dm_list mdas;
+	struct pvcreate_params default_pp;
+
+	fill_default_pvcreate_params(&default_pp);
+	if (!handle)
+		pp = &default_pp;
+	else
+		pp = (struct pvcreate_params *) handle;
 
 	if (pp->idp) {
 		if ((dev = device_from_pvid(cmd, pp->idp)) &&


