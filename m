From: David Teigland <teigland@sourceware.org>
Date: Thu, 28 Feb 2019 10:39:55 -0500
Subject: stable-2.02 - pvscan.service.in: Move StartLimitInterval to Service section
Message-ID: <201902281539.x1SFdt7M003625@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=675b94a11b6e76b241bf84db2c4e318a9658c394
Commit:        675b94a11b6e76b241bf84db2c4e318a9658c394
Parent:        850e95f24a86c4487363c6cf43b10c15a86b0c26
Author:        Marcos Paulo de Souza <mpdesouza@suse.de>
AuthorDate:    Thu Feb 28 09:35:40 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 28 09:38:34 2019 -0600

pvscan.service.in: Move StartLimitInterval to Service section

Without this patch, pvscan service file contains StartLimitInterval at
the Unit section, which trigger an error:

 Unknown lvalue 'StartLimitInterval' in section 'Unit'

Moving StartLimitInterval to Service section fixes the issue.

Signed-off-by: Marcos Paulo de Souza <mpdesouza@suse.de>
---
 scripts/lvm2_pvscan_systemd_red_hat at .service.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/lvm2_pvscan_systemd_red_hat at .service.in b/scripts/lvm2_pvscan_systemd_red_hat at .service.in
index 839bfd1..f0bbd46 100644
--- a/scripts/lvm2_pvscan_systemd_red_hat at .service.in
+++ b/scripts/lvm2_pvscan_systemd_red_hat at .service.in
@@ -2,7 +2,6 @@
 Description=LVM2 PV scan on device %i
 Documentation=man:pvscan(8)
 DefaultDependencies=no
-StartLimitInterval=0
 BindsTo=dev-block-%i.device
 Requires=lvm2-lvmetad.socket
 After=lvm2-lvmetad.socket lvm2-lvmetad.service
@@ -14,3 +13,4 @@ Type=oneshot
 RemainAfterExit=yes
 ExecStart=@SBINDIR@/lvm pvscan --cache --activate ay %i
 ExecStop=@SBINDIR@/lvm pvscan --cache %i
+StartLimitInterval=0


