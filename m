From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 10 Nov 2022 13:22:20 +0000 (GMT)
Subject: main - make: generate
Message-ID: <20221110132220.063233858D20@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6b96bf7bc2f548e7ce1de879251c8b90ab40b634
Commit:        6b96bf7bc2f548e7ce1de879251c8b90ab40b634
Parent:        403779333be419352d6062da592ea78e6096e12b
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Nov 10 09:57:57 2022 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Nov 10 13:58:09 2022 +0100

make: generate

---
 man/vgchange.8_pregen | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index 9df1ef733..7fa1cbb10 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -342,10 +342,12 @@ Reactivate LVs using the latest metadata.
 Change the system ID of a VG.
 .br
 .P
-\fBvgchange\fP \fB--systemid\fP \fIString\fP \fIVG\fP
+\fBvgchange\fP \fB--systemid\fP \fIString\fP \fIVG\fP|\fITag\fP|\fISelect\fP
 .br
 .RS 4
 .ad l
+[ \fB-S\fP|\fB--select\fP \fIString\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE

