From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 14 Feb 2014 11:04:18 +0000 (UTC)
Subject: master - systemd: Use --ignoreskippedcluster in generated activation systemd units
Message-ID: <20140214110418.96ADC608F5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4210219a8bba1aee6a16d16f4c158fa46395b9dd
Commit:        4210219a8bba1aee6a16d16f4c158fa46395b9dd
Parent:        94d8779ae241a2742ed43acc7bb0f98b7b2da25c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 14 11:59:12 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Feb 14 11:59:12 2014 +0100

systemd:  Use --ignoreskippedcluster in generated activation systemd units

When the activation units are generated if use_lvmetad=0 (no
autoactivation), use --ignoreskippedcluster option for vgchange calls
since the cluster with cLVM is set up by separate units.

This avoids a situation in which the generated activation units are
improperly in failed state just because of the vgchange return value
when clustered VGs are encountered while the activation of non-clustered
VGs does proceed normally.
---
 WHATS_NEW                                          |    1 +
 .../lvm2_activation_generator_systemd_red_hat.c    |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 01fa616..e2a33b5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Use --ignoreskippedcluster in activation systemd units if use_lvmetad=0.
   Allow approximate allocation when specifying size in percentage terms.
   Add basic LVM support for cache[pool] segment types.
   Use local exclusive activation for creation of raid in cluster.
diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index f2e2e49..07a2563 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -150,7 +150,7 @@ static int generate_unit(const char *dir, int unit)
 		      "[Service]\n", f);
 	}
 
-	fputs("ExecStart=" LVM_PATH " vgchange -aay --sysinit\n"
+	fputs("ExecStart=" LVM_PATH " vgchange -aay --sysinit --ignoreskippedcluster\n"
 	      "Type=oneshot\n", f);
 
 	if (fclose(f) < 0) {


