From: Vratislav Podzimek <vpodzime@redhat.com>
Date: Fri,  4 Mar 2016 07:59:28 +0100
Subject: [PATCH] Run the DBus daemon with the "C" locale
Message-ID: <1457074768-11160-1-git-send-email-vpodzime@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Otherwise it uses the system default which may be e.g. cs_CZ.UTF-8 causing the
daemon to fail when parsing output from the CLI tools - it for example gets 1,5G
instead of 1.5G.
---
 scripts/lvm2_lvmdbusd_systemd_red_hat.service.in | 1 +
 1 file changed, 1 insertion(+)

diff --git a/scripts/lvm2_lvmdbusd_systemd_red_hat.service.in b/scripts/lvm2_lvmdbusd_systemd_red_hat.service.in
index d3ad870..b7e9ace 100644
--- a/scripts/lvm2_lvmdbusd_systemd_red_hat.service.in
+++ b/scripts/lvm2_lvmdbusd_systemd_red_hat.service.in
@@ -5,6 +5,7 @@ Documentation=man:lvmdbusd(8)
 [Service]
 Type=dbus
 BusName=com.redhat.lvmdbus1
+Environment="LC_ALL=C"
 ExecStart=@sbindir@/lvmdbusd --udev
 
 [Install]
-- 
2.5.0


