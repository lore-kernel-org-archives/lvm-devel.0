From: David Teigland <teigland@sourceware.org>
Date: Fri,  5 Nov 2021 17:45:35 +0000 (GMT)
Subject: main - lvm2-pvscan: include --autoactivation event
Message-ID: <20211105174535.F2CAE3858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5f7cb977438891a073227d75029f61970b1710bd
Commit:        5f7cb977438891a073227d75029f61970b1710bd
Parent:        f40fd88374fe1e911233e5a4fc79223d97decde0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 4 14:14:37 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 4 14:14:37 2021 -0500

lvm2-pvscan: include --autoactivation event

in the pvscan --cache -aay command so that the use
of the command for event activation is explicit.
---
 scripts/lvm2-pvscan.service.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/lvm2-pvscan.service.in b/scripts/lvm2-pvscan.service.in
index 09753e8c9..93749f7a7 100644
--- a/scripts/lvm2-pvscan.service.in
+++ b/scripts/lvm2-pvscan.service.in
@@ -10,5 +10,5 @@ Conflicts=shutdown.target
 [Service]
 Type=oneshot
 RemainAfterExit=yes
-ExecStart=@SBINDIR@/lvm pvscan --cache --activate ay %i
+ExecStart=@SBINDIR@/lvm pvscan --cache --activate ay --autoactivation event %i
 ExecStop=@SBINDIR@/lvm pvscan --cache %i


