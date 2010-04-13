From: agk@sourceware.org <agk@sourceware.org>
Date: 13 Apr 2010 23:57:42 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c tools/toollib.h
Message-ID: <20100413235742.5759.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-13 23:57:42

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c toollib.h 

Log message:
	Use typedefs for toollib process_each functions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1515&r2=1.1516
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.192&r2=1.193
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.72&r2=1.73

--- LVM2/WHATS_NEW	2010/04/13 19:54:16	1.1515
+++ LVM2/WHATS_NEW	2010/04/13 23:57:41	1.1516
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Use typedefs for toollib process_each functions.
   Use C locales and use_mlockall for clvmd.
   Refactor code related to vg->pvs list and add pv->vg link.
   Mask LCK_HOLD flag in cluster VG locks for compatibility reasons.
--- LVM2/tools/toollib.c	2010/04/13 01:54:34	1.192
+++ LVM2/tools/toollib.c	2010/04/13 23:57:41	1.193
@@ -87,7 +87,7 @@
 			  const struct dm_list *arg_lvnames,
 			  const struct dm_list *tags,
 			  void *handle,
-			  process_single_lv_fn_t process_single)
+			  process_single_lv_fn_t process_single_lv)
 {
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
@@ -147,7 +147,7 @@
 		if (!process_lv)
 			continue;
 
-		ret = process_single(cmd, lvl->lv, handle);
+		ret = process_single_lv(cmd, lvl->lv, handle);
 		if (ret > ret_max)
 			ret_max = ret;
 		if (sigint_caught())
@@ -165,9 +165,7 @@
 
 int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 		    uint32_t flags, void *handle,
-		    int (*process_single) (struct cmd_context * cmd,
-					   struct logical_volume * lv,
-					   void *handle))
+		    process_single_lv_fn_t process_single_lv)
 {
 	int opt = 0;
 	int ret_max = ECMD_PROCESSED;
@@ -320,7 +318,7 @@
 		}
 
 		ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg,
-					    handle, process_single);
+					    handle, process_single_lv);
 		unlock_and_release_vg(cmd, vg, vgname);
 		if (ret > ret_max)
 			ret_max = ret;
@@ -335,10 +333,7 @@
 			       struct volume_group *vg,
 			       struct physical_volume *pv,
 			       void *handle,
-			       int (*process_single) (struct cmd_context * cmd,
-						      struct volume_group * vg,
-						      struct pv_segment * pvseg,
-						      void *handle))
+			       process_single_pvseg_fn_t process_single_pvseg)
 {
 	struct pv_segment *pvseg;
 	struct pv_list *pvl;
@@ -373,12 +368,12 @@
 	}
 
 	if (dm_list_empty(&pv->segments)) {
-		ret = process_single(cmd, NULL, &_free_pv_segment, handle);
+		ret = process_single_pvseg(cmd, NULL, &_free_pv_segment, handle);
 		if (ret > ret_max)
 			ret_max = ret;
 	} else
 		dm_list_iterate_items(pvseg, &pv->segments) {
-			ret = process_single(cmd, vg, pvseg, handle);
+			ret = process_single_pvseg(cmd, vg, pvseg, handle);
 			if (ret > ret_max)
 				ret_max = ret;
 			if (sigint_caught())
@@ -396,16 +391,14 @@
 int process_each_segment_in_lv(struct cmd_context *cmd,
 			       struct logical_volume *lv,
 			       void *handle,
-			       int (*process_single) (struct cmd_context * cmd,
-						      struct lv_segment * seg,
-						      void *handle))
+			       process_single_seg_fn_t process_single_seg)
 {
 	struct lv_segment *seg;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 
 	dm_list_iterate_items(seg, &lv->segments) {
-		ret = process_single(cmd, seg, handle);
+		ret = process_single_seg(cmd, seg, handle);
 		if (ret > ret_max)
 			ret_max = ret;
 		if (sigint_caught())
@@ -419,10 +412,7 @@
 			   const char *vgid,
 			   struct dm_list *tags, struct dm_list *arg_vgnames,
 			   uint32_t flags, void *handle, int ret_max,
-			   int (*process_single) (struct cmd_context * cmd,
-						  const char *vg_name,
-						  struct volume_group * vg,
-						  void *handle))
+			   process_single_vg_fn_t process_single_vg)
 {
 	struct volume_group *vg;
 	int ret = 0;
@@ -445,7 +435,7 @@
 			goto out;
 	}
 
-	if ((ret = process_single(cmd, vg_name, vg,
+	if ((ret = process_single_vg(cmd, vg_name, vg,
 				  handle)) > ret_max)
 		ret_max = ret;
 
@@ -459,10 +449,7 @@
 
 int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 		    uint32_t flags, void *handle,
-		    int (*process_single) (struct cmd_context * cmd,
-					   const char *vg_name,
-					   struct volume_group * vg,
-					   void *handle))
+		    process_single_vg_fn_t process_single_vg)
 {
 	int opt = 0;
 	int ret_max = ECMD_PROCESSED;
@@ -529,7 +516,7 @@
 			ret_max = _process_one_vg(cmd, vg_name, vgid, &tags,
 						  &arg_vgnames,
 						  flags, handle,
-					  	  ret_max, process_single);
+					  	  ret_max, process_single_vg);
 			if (sigint_caught())
 				return ret_max;
 		}
@@ -541,7 +528,7 @@
 			ret_max = _process_one_vg(cmd, vg_name, NULL, &tags,
 						  &arg_vgnames,
 						  flags, handle,
-					  	  ret_max, process_single);
+					  	  ret_max, process_single_vg);
 			if (sigint_caught())
 				return ret_max;
 		}
@@ -552,7 +539,7 @@
 
 int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			  const struct dm_list *tags, void *handle,
-			  process_single_pv_fn_t process_single)
+			  process_single_pv_fn_t process_single_pv)
 {
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
@@ -563,7 +550,7 @@
 		    !str_list_match_list(tags, &pvl->pv->tags)) {
 			continue;
 		}
-		if ((ret = process_single(cmd, vg, pvl->pv, handle)) > ret_max)
+		if ((ret = process_single_pv(cmd, vg, pvl->pv, handle)) > ret_max)
 			ret_max = ret;
 		if (sigint_caught())
 			return ret_max;
@@ -573,10 +560,7 @@
 }
 
 static int _process_all_devs(struct cmd_context *cmd, void *handle,
-		    int (*process_single) (struct cmd_context * cmd,
-					   struct volume_group * vg,
-					   struct physical_volume * pv,
-					   void *handle))
+			     process_single_pv_fn_t process_single_pv)
 {
 	struct physical_volume *pv;
 	struct physical_volume pv_dummy;
@@ -605,7 +589,7 @@
 			pv_dummy.fmt = NULL;
 			pv = &pv_dummy;
 		}
-		ret = process_single(cmd, NULL, pv, handle);
+		ret = process_single_pv(cmd, NULL, pv, handle);
 		if (ret > ret_max)
 			ret_max = ret;
 		if (sigint_caught())
@@ -625,10 +609,7 @@
 int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 		    struct volume_group *vg, uint32_t flags,
 		    int scan_label_only, void *handle,
-		    int (*process_single) (struct cmd_context * cmd,
-					   struct volume_group * vg,
-					   struct physical_volume * pv,
-					   void *handle))
+		    process_single_pv_fn_t process_single_pv)
 {
 	int opt = 0;
 	int ret_max = ECMD_PROCESSED;
@@ -721,7 +702,7 @@
 				}
 			}
 
-			ret = process_single(cmd, vg, pv, handle);
+			ret = process_single_pv(cmd, vg, pv, handle);
 			if (ret > ret_max)
 				ret_max = ret;
 			if (sigint_caught())
@@ -740,7 +721,7 @@
 
 				ret = process_each_pv_in_vg(cmd, vg, &tags,
 							    handle,
-							    process_single);
+							    process_single_pv);
 
 				unlock_and_release_vg(cmd, vg, sll->str);
 
@@ -755,13 +736,13 @@
 			log_verbose("Using all physical volume(s) in "
 				    "volume group");
 			ret = process_each_pv_in_vg(cmd, vg, NULL, handle,
-						    process_single);
+						    process_single_pv);
 			if (ret > ret_max)
 				ret_max = ret;
 			if (sigint_caught())
 				goto out;
 		} else if (arg_count(cmd, all_ARG)) {
-			ret = _process_all_devs(cmd, handle, process_single);
+			ret = _process_all_devs(cmd, handle, process_single_pv);
 			if (ret > ret_max)
 				ret_max = ret;
 			if (sigint_caught())
@@ -773,7 +754,7 @@
 				goto bad;
 
 			dm_list_iterate_items(pvl, pvslist) {
-				ret = process_single(cmd, NULL, pvl->pv,
+				ret = process_single_pv(cmd, NULL, pvl->pv,
 						     handle);
 				if (ret > ret_max)
 					ret_max = ret;
--- LVM2/tools/toollib.h	2010/04/13 01:54:34	1.72
+++ LVM2/tools/toollib.h	2010/04/13 23:57:41	1.73
@@ -26,61 +26,60 @@
 struct volume_group *recover_vg(struct cmd_context *cmd, const char *vgname,
 				uint32_t lock_type);
 
+typedef int (*process_single_vg_fn_t) (struct cmd_context * cmd,
+				       const char *vg_name,
+				       struct volume_group * vg,
+				       void *handle);
+typedef int (*process_single_pv_fn_t) (struct cmd_context *cmd,
+				  struct volume_group *vg,
+				  struct physical_volume *pv,
+				  void *handle);
+typedef int (*process_single_lv_fn_t) (struct cmd_context *cmd,
+				  struct logical_volume *lv,
+				  void *handle);
+typedef int (*process_single_seg_fn_t) (struct cmd_context * cmd,
+					struct lv_segment * seg,
+					void *handle);
+typedef int (*process_single_pvseg_fn_t) (struct cmd_context * cmd,
+					  struct volume_group * vg,
+					  struct pv_segment * pvseg,
+					  void *handle);
+
 int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 		    uint32_t flags, void *handle,
-		    int (*process_single) (struct cmd_context * cmd,
-					   const char *vg_name,
-					   struct volume_group * vg,
-					   void *handle));
+		    process_single_vg_fn_t process_single_vg);
 
 int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 		    struct volume_group *vg, uint32_t lock_type,
 		    int scan_label_only, void *handle,
-		    int (*process_single) (struct cmd_context * cmd,
-					   struct volume_group * vg,
-					   struct physical_volume * pv,
-					   void *handle));
+		    process_single_pv_fn_t process_single_pv);
 
 int process_each_segment_in_pv(struct cmd_context *cmd,
 			       struct volume_group *vg,
 			       struct physical_volume *pv,
 			       void *handle,
-			       int (*process_single) (struct cmd_context * cmd,
-						      struct volume_group * vg,
-						      struct pv_segment * pvseg,
-						      void *handle));
+			       process_single_pvseg_fn_t process_single_pvseg);
 
 int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 		    uint32_t flags, void *handle,
-		    int (*process_single) (struct cmd_context * cmd,
-					   struct logical_volume * lv,
-					   void *handle));
+		    process_single_lv_fn_t process_single_lv);
+
 
 int process_each_segment_in_lv(struct cmd_context *cmd,
 			       struct logical_volume *lv, void *handle,
-			       int (*process_single) (struct cmd_context * cmd,
-						      struct lv_segment * seg,
-						      void *handle));
-
-typedef int (*process_single_pv_fn_t) (struct cmd_context *cmd,
-				  struct volume_group *vg,
-				  struct physical_volume *pv,
-				  void *handle);
+			       process_single_seg_fn_t process_single_seg);
 
 int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			  const struct dm_list *tags, void *handle,
-			  process_single_pv_fn_t process_single);
+			  process_single_pv_fn_t process_single_pv);
 
-typedef int (*process_single_lv_fn_t) (struct cmd_context *cmd,
-				  struct logical_volume *lv,
-				  void *handle);
 
 int process_each_lv_in_vg(struct cmd_context *cmd,
 			  struct volume_group *vg,
 			  const struct dm_list *arg_lvnames,
 			  const struct dm_list *tags,
 			  void *handle,
-			  process_single_lv_fn_t process_single);
+			  process_single_lv_fn_t process_single_lv);
 
 char *default_vgname(struct cmd_context *cmd);
 const char *extract_vgname(struct cmd_context *cmd, const char *lv_name);
@@ -118,5 +117,4 @@
 int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
 		      uint32_t *stripe_size);
 
-
 #endif


