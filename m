From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 22 Aug 2013 06:29:39 +0000 (UTC)
Subject: master - systemd: lvm2-activation-generator: report only error otherwise be silent
Message-ID: <20130822062939.4A93060DF5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=99fe3b88d270fa310d05dd093bea6dd74dc75642
Commit:        99fe3b88d270fa310d05dd093bea6dd74dc75642
Parent:        c8daa15270e0e1085776bd227331863e7cf408ae
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 22 08:14:11 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 22 08:27:51 2013 +0200

systemd: lvm2-activation-generator: report only error otherwise be silent

Do not print success status for lvm2-activation-generator:

  "LVM: Activation generator successfully completed."
  "LVM: Logical Volume autoactivation enabled." (if use_lvmetad=1)

Though this information is quite useful during boot, it may
be confusing for users if it happens anytime later and it
actually happens if systemd reloads. This is usually on package
update to update the systemd state and load any new units that are
newly installed in the system. The systemd reload is global and
so any existing generators are rerun at that moment too.
---
 WHATS_NEW                                          |    1 +
 .../lvm2_activation_generator_systemd_red_hat.c    |    8 +++-----
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6c0514f..76c2ebb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Make lvm2-activation-generator silent unless it's in error state.
   Remove "mpath major is not dm major" msg for mpath component scan (2.02.94).
   Prevent cluster mirror logs from being corrupted by redundant checkpoints.
   Fix ignored lvmetad update on loop device configuration (2.02.99).
diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index 9d4b581..9cec0a9 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -180,10 +180,8 @@ int main(int argc, char *argv[])
 	}
 
 	/* If lvmetad used, rely on autoactivation instead of direct activation. */
-	if (lvm_uses_lvmetad()) {
-		kmsg(LOG_DEBUG, "LVM: Logical Volume autoactivation enabled.\n");
+	if (lvm_uses_lvmetad())
 		goto out;
-	}
 
 	dir = argc > 1 ? argv[1] : DEFAULT_UNIT_DIR;
 
@@ -192,8 +190,8 @@ int main(int argc, char *argv[])
 	    !generate_unit(dir, UNIT_NET))
 		r = EXIT_FAILURE;
 out:
-	kmsg(r ? LOG_ERR : LOG_DEBUG, "LVM: Activation generator %s.\n",
-	     r ? "failed" : "successfully completed");
+	if (r)
+		kmsg(LOG_ERR, "LVM: Activation generator failed.\n");
 	if (kmsg_fd != -1)
 		(void) close(kmsg_fd);
 	return r;


