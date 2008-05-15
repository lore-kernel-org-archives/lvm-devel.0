From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 15 May 2008 14:45:26 -0500
Subject: LVM2 patch to clean-up --resync on cluster mirrors
Message-ID: <1210880726.12317.3.camel@hydrogen>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If an LV is clustered, it must be deactivated before activating excl.  So,
we move the deactivate so an LV is deactivated regardless.  Then if
clustered, we activate excl (to ensure no-one else has it open/active),
and deactivate.

This should save us crappy messages like:
[root at bp-xen-01 ~]# lvchange --resync vg/lv1
Do you really want to deactivate logical volume lv1 to resync it? [y/n]: y
  Error locking on node bp-xen-01: Volume is busy on another node
  Can't get exclusive access to clustered volume lv1

Index: LVM2-cvs/tools/lvchange.c
===================================================================
--- LVM2-cvs.orig/tools/lvchange.c
+++ LVM2-cvs/tools/lvchange.c
@@ -221,15 +221,18 @@ static int lvchange_resync(struct cmd_co
 		}
 	}
 
+	if (!deactivate_lv(cmd, lv)) {
+		log_error("Unable to deactivate %s for resync", lv->name);
+		return 0;
+	}
+
 	if (vg_is_clustered(lv->vg) && !activate_lv_excl(cmd, lv)) {
 		log_error("Can't get exclusive access to clustered volume %s",
 			  lv->name);
 		return ECMD_FAILED;
-	}
-
-	if (!deactivate_lv(cmd, lv)) {
+	} else if (!deactivate_lv(cmd, lv)) {
 		log_error("Unable to deactivate %s for resync", lv->name);
-		return 0;
+		return ECMD_FAILED;
 	}
 
 	log_lv = first_seg(lv)->log_lv;



