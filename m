From: Petr Rockai <prockai@redhat.com>
Date: Thu, 22 Jan 2009 11:10:08 +0100
Subject: [PATCH 12/14] Port process_each_pv to new vg_read.
In-Reply-To: <1232619010-4858-12-git-send-email-prockai@redhat.com>
References: <1232619010-4858-1-git-send-email-prockai@redhat.com>
	<1232619010-4858-2-git-send-email-prockai@redhat.com>
	<1232619010-4858-3-git-send-email-prockai@redhat.com>
	<1232619010-4858-4-git-send-email-prockai@redhat.com>
	<1232619010-4858-5-git-send-email-prockai@redhat.com>
	<1232619010-4858-6-git-send-email-prockai@redhat.com>
	<1232619010-4858-7-git-send-email-prockai@redhat.com>
	<1232619010-4858-8-git-send-email-prockai@redhat.com>
	<1232619010-4858-9-git-send-email-prockai@redhat.com>
	<1232619010-4858-10-git-send-email-prockai@redhat.com>
	<1232619010-4858-11-git-send-email-prockai@redhat.com>
	<1232619010-4858-12-git-send-email-prockai@redhat.com>
Message-ID: <1232619010-4858-13-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Wed Jan 21 15:52:44 CET 2009  Petr Rockai <me@mornfall.net>
  * Port process_each_pv to new vg_read.
diff -rN -u -p old-temp.4430/tools/pvdisplay.c new-temp.4430/tools/pvdisplay.c
--- old-temp.4430/tools/pvdisplay.c	2009-01-22 11:02:54.986780827 +0100
+++ new-temp.4430/tools/pvdisplay.c	2009-01-22 11:02:55.074781398 +0100
@@ -110,6 +110,6 @@ int pvdisplay(struct cmd_context *cmd, i
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_pv(cmd, argc, argv, NULL, LCK_VG_READ, NULL,
+	return process_each_pv(cmd, argc, argv, NULL, 0, NULL,
 			       _pvdisplay_single);
 }
diff -rN -u -p old-temp.4430/tools/pvresize.c new-temp.4430/tools/pvresize.c
--- old-temp.4430/tools/pvresize.c	2009-01-22 11:02:54.986780827 +0100
+++ new-temp.4430/tools/pvresize.c	2009-01-22 11:02:55.074781398 +0100
@@ -213,7 +213,7 @@ int pvresize(struct cmd_context *cmd, in
 	params.done = 0;
 	params.total = 0;
 
-	ret = process_each_pv(cmd, argc, argv, NULL, LCK_VG_WRITE, &params,
+	ret = process_each_pv(cmd, argc, argv, NULL, READ_FOR_UPDATE, &params,
 			      _pvresize_single);
 
 	log_print("%d physical volume(s) resized / %d physical volume(s) "
diff -rN -u -p old-temp.4430/tools/reporter.c new-temp.4430/tools/reporter.c
--- old-temp.4430/tools/reporter.c	2009-01-22 11:02:54.986780827 +0100
+++ new-temp.4430/tools/reporter.c	2009-01-22 11:02:55.074781398 +0100
@@ -353,7 +353,7 @@ static int _report(struct cmd_context *c
 		break;
 	case PVS:
 		if (args_are_pvs)
-			r = process_each_pv(cmd, argc, argv, NULL, LCK_VG_READ,
+			r = process_each_pv(cmd, argc, argv, NULL, 0,
 					    report_handle, &_pvs_single);
 		else
 			r = process_each_vg(cmd, argc, argv, 0,
@@ -365,7 +365,7 @@ static int _report(struct cmd_context *c
 		break;
 	case PVSEGS:
 		if (args_are_pvs)
-			r = process_each_pv(cmd, argc, argv, NULL, LCK_VG_READ,
+			r = process_each_pv(cmd, argc, argv, NULL, 0,
 					    report_handle, &_pvsegs_single);
 		else
 			r = process_each_vg(cmd, argc, argv, 0,
diff -rN -u -p old-temp.4430/tools/toollib.c new-temp.4430/tools/toollib.c
--- old-temp.4430/tools/toollib.c	2009-01-22 11:02:54.986780827 +0100
+++ new-temp.4430/tools/toollib.c	2009-01-22 11:02:55.074781398 +0100
@@ -578,7 +578,7 @@ static int _process_all_devs(struct cmd_
 }
 
 int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
-		    struct volume_group *vg, uint32_t lock_type, void *handle,
+		    struct volume_group *vg, uint32_t flags, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   struct volume_group * vg,
 					   struct physical_volume * pv,
@@ -673,25 +673,11 @@ int process_each_pv(struct cmd_context *
 		if (!dm_list_empty(&tags) && (vgnames = get_vgs(cmd, 0)) &&
 			   !dm_list_empty(vgnames)) {
 			dm_list_iterate_items(sll, vgnames) {
-				if (!lock_vol(cmd, sll->str, lock_type)) {
-					log_error("Can't lock %s: skipping", sll->str);
-					continue;
-				}
-				if (!(vg = vg_read_internal(cmd, sll->str, NULL, &consistent))) {
-					log_error("Volume group \"%s\" not found", sll->str);
-					unlock_vg(cmd, sll->str);
+				vg = vg_read(cmd, sll->str, NULL, flags);
+				if (vg_read_error(vg)) {
 					ret_max = ECMD_FAILED;
 					continue;
 				}
-				if (!consistent) {
-					unlock_vg(cmd, sll->str);
-					continue;
-				}
-
-				if (!vg_check_status(vg, CLUSTERED)) {
-					unlock_vg(cmd, sll->str);
-					continue;
-				}
 
 				ret = process_each_pv_in_vg(cmd, vg, &tags,
 							    handle,
diff -rN -u -p old-temp.4430/tools/vgreduce.c new-temp.4430/tools/vgreduce.c
--- old-temp.4430/tools/vgreduce.c	2009-01-22 11:02:54.986780827 +0100
+++ new-temp.4430/tools/vgreduce.c	2009-01-22 11:02:55.078780998 +0100
@@ -570,7 +570,7 @@ int vgreduce(struct cmd_context *cmd, in
 
 		/* FIXME: Pass private struct through to all these functions */
 		/* and update in batch here? */
-		ret = process_each_pv(cmd, argc, argv, vg, LCK_NONE, NULL,
+		ret = process_each_pv(cmd, argc, argv, vg, DISABLE_LOCK, NULL,
 				      _vgreduce_single);
 
 	}


