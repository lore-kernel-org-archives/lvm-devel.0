From: Vratislav Podzimek <vpodzime@redhat.com>
Date: Thu, 25 Feb 2016 16:34:41 +0100
Subject: [PATCH] Fix the systemd service providing the DBus service
In-Reply-To: <1456414481-22196-1-git-send-email-vpodzime@redhat.com>
References: <1456414481-22196-1-git-send-email-vpodzime@redhat.com>
Message-ID: <1456414481-22196-2-git-send-email-vpodzime@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

It's lvm2-lvmdbusd.service not lvmdbusd.service. This makes the bus-activation
(auto-activation) work.

Signed-off-by: Vratislav Podzimek <vpodzime@redhat.com>
---
 scripts/com.redhat.lvmdbus1.service.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/com.redhat.lvmdbus1.service.in b/scripts/com.redhat.lvmdbus1.service.in
index e271b08..5578ed1 100644
--- a/scripts/com.redhat.lvmdbus1.service.in
+++ b/scripts/com.redhat.lvmdbus1.service.in
@@ -2,4 +2,4 @@
 Name=com.redhat.lvmdbus1
 Exec=@sbindir@/lvmdbusd --udev
 User=root
-SystemdService=lvmdbusd.service
+SystemdService=lvm2-lvmdbusd.service
-- 
2.5.0


