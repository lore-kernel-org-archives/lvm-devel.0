From: wgh@torlan.ru <wgh@torlan.ru>
Date: Wed, 22 Apr 2020 00:16:29 +0300
Subject: [PATCH] Fix scripts/lvmlocks.service.in using nonexistent --lock-opt autowait
Message-ID: <20200421211629.425256-1-wgh@torlan.ru>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Maxim Plotnikov <wgh@torlan.ru>

The --lock-opt autowait was dropped back in 9ab6bdce01,
and attempting to specify it has quite an opposite effect:
no waiting is done, which makes the unit almost useless.
---
 scripts/lvmlocks.service.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/lvmlocks.service.in b/scripts/lvmlocks.service.in
index f6a951f19..a3d0bd48d 100644
--- a/scripts/lvmlocks.service.in
+++ b/scripts/lvmlocks.service.in
@@ -8,7 +8,7 @@ Type=oneshot
 RemainAfterExit=yes
 
 # start lockspaces and wait for them to finish starting
-ExecStart=@SBINDIR@/lvm vgchange --lock-start --lock-opt autowait
+ExecStart=@SBINDIR@/lvm vgchange --lock-start --lock-opt auto
 
 # stop lockspaces and wait for them to finish stopping
 ExecStop=@SBINDIR@/lvmlockctl --stop-lockspaces --wait 1
-- 
2.24.1



