From: Marcos Paulo de Souza <marcos.souza.org@gmail.com>
Date: Wed, 13 Feb 2019 08:57:41 -0200
Subject: 2018-12-7-stable - pvscan.service.in: Move StartLimitInterval to Service section
Message-ID: <20190213105741.110585-1-marcos.souza.org@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Marcos Paulo de Souza <mpdesouza@suse.de>

Without this patch, pvscan service file contains StartLimitInterval at
the Unit section, which trigger an error:

systemd[1]: [/etc/systemd/system/lvm2-pvscan at .service:5] Unknown lvalue 'StartLimitInterval' in section 'Unit'

Moving StartLimitInterval to Service section fixes the issue.

Signed-off-by: Marcos Paulo de Souza <mpdesouza@suse.de>
---
 This patch applies in version v2_02_183.

 scripts/lvm2_pvscan_systemd_red_hat at .service.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/lvm2_pvscan_systemd_red_hat at .service.in b/scripts/lvm2_pvscan_systemd_red_hat at .service.in
index 839bfd177..f0bbd462d 100644
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
-- 
2.16.4


