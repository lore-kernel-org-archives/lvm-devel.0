From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Feb 2011 15:02:26 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c
Message-ID: <20110218150226.11654.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-18 15:02:26

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c 

Log message:
	Add some backtraces for error paths in process_each_lv

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1920&r2=1.1921
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.220&r2=1.221

--- LVM2/WHATS_NEW	2011/02/18 14:47:28	1.1920
+++ LVM2/WHATS_NEW	2011/02/18 15:02:25	1.1921
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Add stack backtraces for error paths in process_each_lv().
   Fixing some const cast gcc warnings in the code.
   Use char* arithmetic in _text_write(), _text_read() & send_message().
   Fix compilation when devmapper is dissabled.
--- LVM2/tools/toollib.c	2011/02/18 14:47:31	1.220
+++ LVM2/tools/toollib.c	2011/02/18 15:02:25	1.221
@@ -169,8 +169,10 @@
 		}
 		if (ret > ret_max)
 			ret_max = ret;
-		if (sigint_caught())
+		if (sigint_caught()) {
+			stack;
 			return ret_max;
+		}
 	}
 
 	if (lvargs_supplied && lvargs_matched != dm_list_size(arg_lvnames)) {
@@ -253,8 +255,10 @@
 				while (*lv_name == '/')
 					lv_name++;
 				if (!(vgname = extract_vgname(cmd, vgname))) {
-					if (ret_max < ECMD_FAILED)
+					if (ret_max < ECMD_FAILED) {
+						stack;
 						ret_max = ECMD_FAILED;
+					}
 					continue;
 				}
 			} else if (!dev_dir_found &&
@@ -348,8 +352,10 @@
 						    tags_arg, &failed_lvnames,
 						    handle, process_single_lv);
 			if (ret != ECMD_PROCESSED ||
-			    dm_list_empty(&failed_lvnames))
+			    dm_list_empty(&failed_lvnames)) {
+				stack;
 				break;
+			}
 
 			/* Try again with failed LVs in this VG */
 			dm_list_init(&lvnames);
@@ -357,6 +363,7 @@
 
 			free_cmd_vgs(&cmd_vgs);
 			if (!cmd_vg_read(cmd, &cmd_vgs)) {
+				stack;
 				ret = ECMD_FAILED; /* break */
 				break;
 			}
@@ -366,8 +373,10 @@
 
 		free_cmd_vgs(&cmd_vgs);
 		/* FIXME: logic for breaking command is not consistent */
-		if (sigint_caught())
+		if (sigint_caught()) {
+			stack;
 			return ECMD_FAILED;
+		}
 	}
 
 	return ret_max;


