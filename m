From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 24 Jul 2013 09:08:53 +0000 (UTC)
Subject: master - systemd: udevadm settle for lvm2-activation-net.service
Message-ID: <20130724090854.0278F610F3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a03609dee4770f2453b1f5cb851e2169c539b1e4
Commit:        a03609dee4770f2453b1f5cb851e2169c539b1e4
Parent:        cf09cf0cd398d97e41f406aee5fa6b07c23a563b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 24 11:06:28 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 24 11:06:38 2013 +0200

systemd: udevadm settle for lvm2-activation-net.service

In case lvmetad is not used, we need to wait for udev to complete
after net-attached storage is initialized (after iscsi/fcoe service).
N.B. This also requires the storage to be attached synchronously
in the kernel itself.
---
 .../lvm2_activation_generator_systemd_red_hat.c    |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index d257479..17bc71a 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -135,20 +135,22 @@ static int generate_unit(const char *dir, int unit)
 
 	if (unit == UNIT_NET) {
 		fputs("After=iscsi.service fcoe.service\n"
-		      "Before=remote-fs.target shutdown.target\n", f);
+		      "Before=remote-fs.target shutdown.target\n\n"
+		      "[Service]\n"
+		      "ExecStartPre=/usr/bin/udevadm settle\n", f);
 	} else {
 		if (unit == UNIT_EARLY) {
-			fputs("After=systemd-udev-settle.service\n", f);
-			fputs("Before=cryptsetup.target\n", f);
+			fputs("After=systemd-udev-settle.service\n"
+			      "Before=cryptsetup.target\n", f);
 		} else
 			fputs("After=lvm2-activation-early.service cryptsetup.target\n", f);
 
 		fputs("Before=local-fs.target shutdown.target\n"
-		      "Wants=systemd-udev-settle.service\n\n", f);
+		      "Wants=systemd-udev-settle.service\n\n"
+		      "[Service]\n", f);
 	}
 
-	fputs("[Service]\n"
-	      "ExecStart=/usr/sbin/lvm vgchange -aay --sysinit\n"
+	fputs("ExecStart=/usr/sbin/lvm vgchange -aay --sysinit\n"
 	      "Type=oneshot\n", f);
 
 	if (fclose(f) < 0) {


