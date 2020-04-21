From: David Teigland <teigland@sourceware.org>
Date: Tue, 21 Apr 2020 21:53:22 +0000 (GMT)
Subject: master - Fix scripts/lvmlocks.service.in using nonexistent --lock-opt autowait
Message-ID: <20200421215322.05D57386F02B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a509776588a5c0c0bfc2394e4d1ed717531b0257
Commit:        a509776588a5c0c0bfc2394e4d1ed717531b0257
Parent:        d79afd408446e3eb922d16954ae630a7af995e66
Author:        Maxim Plotnikov <wgh@torlan.ru>
AuthorDate:    Wed Apr 22 00:16:29 2020 +0300
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 21 16:52:45 2020 -0500

Fix scripts/lvmlocks.service.in using nonexistent --lock-opt autowait

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



