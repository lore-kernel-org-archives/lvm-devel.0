From: Milan Broz <mbroz@redhat.com>
Date: Thu, 05 Feb 2009 19:06:12 +0100
Subject: [PATCH] lvconvert --repair
In-Reply-To: <87skn1p0jo.fsf@eriador.mornfall.net>
References: <87skn1p0jo.fsf@eriador.mornfall.net>
Message-ID: <498B2A94.7050105@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Petr Rockai wrote:
> The first patch is just a few minor bits in the testing infrastructure, not
> overly important (but it is needed for the new t-lvconvent-repair.sh testcase
> to pass, due to vgreduce --removemissing return code).

This is the only important chunk in this patch, simple bugfix

--- old-lvconvert-reorder-2/tools/vgreduce.c	2009-01-30 11:03:12.589282389 +0100
+++ new-lvconvert-reorder-2/tools/vgreduce.c	2009-01-30 11:03:12.685281881 +0100
@@ -575,6 +575,8 @@ int vgreduce(struct cmd_context *cmd, in
 		if (fixed)
 			log_print("Wrote out consistent volume group %s",
 				  vg_name);
+		else
+			ret = ECMD_FAILED;
 
 	} else {
 		if (!vg_check_status(vg, EXPORTED_VG | LVM_WRITE | RESIZEABLE_VG)) {

ACK, but as a separate fix/commit

Also there should be
-	int ret = 1;
+	int ret = ECMD_PROCESSED;

to be consistent enough...

Acked-by: Milan Broz <mbroz@redhat.com>


-------
> The second patch does the actual implementation. It should be up to date with
> CVS as of today. It should be relatively straightforward, although it did
> require adding MISSING_PV checks to some places that were missing them (it's
> been harmless till now, since no allocation was ever done on VGs with PVs
> missing, but it's crucial for lvconvert --repair).


- missing man page update

--- old-lvconvert-reorder-2/lib/metadata/pv_map.c	2009-01-30 11:03:20.569284247 +0100
+++ new-lvconvert-reorder-2/lib/metadata/pv_map.c	2009-01-30 11:03:20.625285639 +0100
@@ -129,6 +129,11 @@ static int _create_maps(struct dm_pool *
 	dm_list_iterate_items(pvl, pvs) {
 		if (!(pvl->pv->status & ALLOCATABLE_PV))
 			continue;
+		if (pvl->pv->status & MISSING_PV) {
+			log_very_verbose("skipping missing pv ...");

Do we have name of PV (hint in metadata?) or something to print here?


diff -rN -u -p old-lvconvert-reorder-2/tools/lvconvert.c new-lvconvert-reorder-2/tools/lvconvert.c
--- old-lvconvert-reorder-2/tools/lvconvert.c	2009-01-30 11:03:20.573279378 +0100
+++ new-lvconvert-reorder-2/tools/lvconvert.c	2009-01-30 11:03:20.661284767 +0100
@@ -364,6 +364,61 @@ static int _insert_lvconvert_layer(struc
 	return 1;
 }
 
+static int _area_missing(struct lv_segment *lvseg, int s)
+{
+	if (seg_type(lvseg, s) == AREA_LV) {
+		if (seg_lv(lvseg, s)->status & PARTIAL_LV)
+			return 1;
+	} else if (seg_type(lvseg, s) == AREA_PV) {
+		if (seg_pv(lvseg, s)->status & MISSING_PV)
+			return 1;
+	}
+	return 0;
+}
+
+/* FIXME we want to handle mirror stacks here... */
+static int _count_failed_mirrors(struct logical_volume *lv)
+{
+	struct lv_segment *lvseg;
+	int ret = 0;
+	int s;
+	dm_list_iterate_items(lvseg, &lv->segments) {
+		if (!seg_is_mirrored(lvseg))
+			return -1;

why -1 here and not simply continue or return_0 ?

If this can really happen, it adds mirror lp->mirrors...

		int failed_mirrors = 0;
		...
		failed_mirrors = _count_failed_mirrors(lv);
		lp->mirrors -= failed_mirrors;
		log_error("Mirror status: %d/%d legs failed.",
			  failed_mirrors, existing_mirrors);
...

+		for(s = 0; s < lvseg->area_count; ++s) {
+			if (_area_missing(lvseg, s))
+				++ ret;
+		}
+	}
+	return ret;
+}


+static struct dm_list *_failed_pv_list(struct cmd_context *cmd,
+				       struct volume_group *vg)
+{
+	struct dm_list *r;
+	struct pv_list *pvl, *new_pvl;
+
+	if (!(r = dm_pool_alloc(cmd->mem, sizeof(*r)))) {
+		log_error("Allocation of list failed");
+		return_0;
+	}
+
+	dm_list_init(r);
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (!(pvl->pv->status & MISSING_PV))
+			continue;
+
+		if (!(new_pvl = dm_pool_alloc(cmd->mem, sizeof(*new_pvl)))) {
+			log_err("Unable to allocate physical volume list.");
+			return 0;

s/log_err/log_error, return_0 :)

also it should check for 0 othewwise it expects empty list (not NULL) later
I mean this

		- lp->pvh = _failed_pv_list(cmd, lv->vg);

		+ if (!(lp->pvh = ...)
		+	return_0; 


+	if (arg_count(cmd,repair_ARG)) {
+		cmd->handles_missing_pvs = 1;
+		cmd->partial_activation = 1;
+		lp->need_polling = 0;
+		if (!(lv->status & PARTIAL_LV)) {
+			log_error("The mirror is consistent, nothing to repair.");
+			return_0;

why return_0? PEBKAC :)

+		}
+		failed_mirrors = _count_failed_mirrors(lv);
see above

+		lp->mirrors -= failed_mirrors;
+		log_error("Mirror status: %d/%d legs failed.",
+			  failed_mirrors, existing_mirrors);
+		old_pvh = lp->pvh;
+		lp->pvh = _failed_pv_list(cmd, lv->vg);
ditto

+		log_lv=first_seg(lv)->log_lv;

Someone could say that there should be space before and after equal sign :-]


@@ -455,6 +538,18 @@ static int lvconvert_mirrors(struct cmd_
 	}
 
 	/*
+	 * FIXME This check used to precede mirror->mirror conversion
+	 * but didn't affect mirror->linear or linear->mirror. I do
+	 * not understand what is its intention, in fact.
+	 */
+	if (dm_list_size(&lv->segments) != 1) {
+		log_error("Logical volume %s has multiple "
+			  "mirror segments.", lv->name);
+		return 0;
+	}

I think we temporarily restrict mirrors to only one segment mirrors.
Linear can have more segments of course.

There is probably gap in logic, if combined with --alloc anywhere...
(But trying to test that I found another error:-)

----
Why this testcase doesn't work (resp. doesn't finish without
manual intervention and hangs in lvconvert?)
It seems that some devices are left suspended...

prepare_vg 3

lvcreate --alloc anywhere -m1 -L 1 -n mirror $vg

dd if=/dev/zero of=$dev1 bs=1M count=1

#not vgreduce -v --removemissing $vg
lvconvert --repair $vg/mirror
vgreduce --removemissing $vg


Milan
--
mbroz at redhat.com


