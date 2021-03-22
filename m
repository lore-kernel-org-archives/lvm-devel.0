From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:19 +0000 (GMT)
Subject: dev-next - lvresize: allow mixing striped with errors or zero
Message-ID: <20210322153919.B2AFE3854808@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7a9efc5fae713a09cc1d1238a19a1cac555fb364
Commit:        7a9efc5fae713a09cc1d1238a19a1cac555fb364
Parent:        b35ef9d67cabd23f65e2ee2113af46bea095138c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 18 13:19:45 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 18 18:56:49 2021 +0100

lvresize: allow mixing striped with errors or zero

Enabled extension/mixing of stripes/linears, error and zero
segtype LVs with stripes/linear, error and zero segtypes.

It is not very useful in practice, as the user cannot store any real
data on error or zero segtypes, but it may get some uses in
some scenarios where i.e. some portion of the device should not be
readable. Mixing of types happens on 'extent_size' level:

  lvcreate -L1 -n lv vg
  lvextend --type error  -L+1 vg/lv
  lvextend --type zero   -L+1 vg/lv
  lvextend --type linear -L+1 vg/lv
  lvextend --type striped -L+1 vg/lv

  lvs -o+segtype,seg_size vg

Note: when the type is not specified, the last segment type is
automatically selected.

It's also a small 'can of worms' since we can't tell LVs if
the LV is linear/error/zero or their mixtures. So the meaning behind
them may need some updates.

We already have this types of LV created i.e by:

  vgreduce --removemissing --force

where missing LV segments have been replaced by either
error or zero segtype (lvm.conf).

TODO: it might be worth adding a message while such device is activated.
---
 lib/metadata/lv_manip.c | 26 +++++++++++++++++++-------
 tools/lvresize.c        | 17 +++++++++++++++--
 2 files changed, 34 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 803f76052..81346bd1a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5456,15 +5456,27 @@ static int _lvresize_adjust_extents(struct logical_volume *lv,
 
 	seg_last = last_seg(lv);
 
-	/* FIXME Support LVs with mixed segment types */
-	if (lp->segtype && (lp->segtype != seg_last->segtype)) {
-		log_error("VolumeType does not match (%s).", lp->segtype->name);
-		return 0;
+	if (!lp->segtype)
+		/* Use segment type of last segment */
+		lp->segtype = seg_last->segtype;
+	else if (lp->segtype != seg_last->segtype) {
+		/* Support newseg error or zero with lastseg striped
+		 * and newseg striped with lastseg error or zero */
+		if ((segtype_is_error(lp->segtype) || segtype_is_zero(lp->segtype) ||
+		     segtype_is_striped(lp->segtype)) &&
+		    (segtype_is_striped(seg_last->segtype) ||
+		     segtype_is_error(seg_last->segtype) || segtype_is_zero(seg_last->segtype))) {
+			if (!lp->stripes)
+				lp->stripes = 1;
+		} else {
+			log_error("VolumeType does not match (%s).", lp->segtype->name);
+			return 0;
+		}
+		/* FIXME Support more LVs with mixed segment types */
+		log_print_unless_silent("Logical volume %s is using mixing segment types %s and %s.",
+					display_lvname(lv), seg_last->segtype->name, lp->segtype->name);
 	}
 
-	/* Use segment type of last segment */
-	lp->segtype = seg_last->segtype;
-
 	/* For virtual devices, just pretend the physical size matches. */
 	existing_physical_extents = saved_existing_physical_extents = _lv_pe_count(lv);
 	if (!existing_physical_extents) {
diff --git a/tools/lvresize.c b/tools/lvresize.c
index a3c17a744..f39f03a40 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -20,9 +20,17 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 {
 	const char *cmd_name = command_name(cmd);
 	const char *type_str = arg_str_value(cmd, type_ARG, NULL);
+	int only_linear = 0;
 
-	if (type_str && !(lp->segtype = get_segtype_from_string(cmd, type_str)))
-		return_0;
+	if (type_str) {
+		if (!strcmp(type_str, "linear")) {
+			type_str = "striped";
+			only_linear = 1; /* User requested linear only target */
+		}
+
+		if (!(lp->segtype = get_segtype_from_string(cmd, type_str)))
+			return_0;
+	}
 
 	if (!strcmp(cmd_name, "lvreduce"))
 		lp->resize = LV_REDUCE;
@@ -137,6 +145,11 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 		return 0;
 	}
 
+	if (only_linear && lp->stripes > 1) {
+		log_error("Cannot use stripes with linear type.");
+		return 0;
+	}
+
 	if ((lp->stripe_size = arg_uint64_value(cmd, stripesize_ARG, 0)) &&
 	    (arg_sign_value(cmd, stripesize_ARG, SIGN_NONE) == SIGN_MINUS)) {
 		log_error("Stripesize may not be negative.");


