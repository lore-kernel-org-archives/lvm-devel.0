From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 12 Jul 2010 11:37:50 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c
Message-ID: <20100712113750.27091.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-07-12 11:37:50

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 

Log message:
	Add more verbose messages while checking volume_list and hosttags settings.
	
	This should bring less confusion when there are some settings left and
	people just forgot about it and then they run into problems. These messages
	should give them a hint of what's really going on.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1663&r2=1.1664
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.171&r2=1.172

--- LVM2/WHATS_NEW	2010/07/09 17:01:11	1.1663
+++ LVM2/WHATS_NEW	2010/07/12 11:37:49	1.1664
@@ -1,5 +1,6 @@
 Version 2.02.71 -
 ===============================
+  Add more verbose messages while checking volume_list and hosttags settings.
   Add log_error when strdup fails in {vg|lv}_change_tag().
   Remove unnecessary includes in liblvm files.
   Use __attribute__ consistently throughout.
--- LVM2/lib/activate/activate.c	2010/07/08 12:24:04	1.171
+++ LVM2/lib/activate/activate.c	2010/07/12 11:37:50	1.172
@@ -262,6 +262,9 @@
 	char path[PATH_MAX];
 
 	if (!(cn = find_config_tree_node(cmd, "activation/volume_list"))) {
+		log_verbose("activation/volume_list configuration setting "
+			    "not defined, checking host tags only");
+
 		/* If no host tags defined, activate */
 		if (dm_list_empty(&cmd->tags))
 			return 1;
@@ -271,11 +274,18 @@
 		    str_list_match_list(&cmd->tags, &lv->vg->tags))
 			return 1;
 
+		log_verbose("No host tag matches %s/%s",
+			    lv->vg->name, lv->name);
+
 		/* Don't activate */
 		return 0;
 	}
 
 	for (cv = cn->v; cv; cv = cv->next) {
+		log_verbose("activation/volume_list configuration setting "
+			    "defined, checking the list to match %s/%s",
+			    lv->vg->name, lv->name);
+
 		if (cv->type != CFG_STRING) {
 			log_error("Ignoring invalid string in config file "
 				  "activation/volume_list");
@@ -330,6 +340,9 @@
 			return 1;
 	}
 
+	log_verbose("No item supplied in activation/volume_list configuration "
+		    "setting matches %s/%s", lv->vg->name, lv->name);
+
 	return 0;
 }
 


