From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 10 Jul 2022 23:22:27 +0000 (GMT)
Subject: main - make: generate
Message-ID: <20220710232227.7178C385737B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c0f8e6675c62332263acdc7c3c2f61eca20bd60f
Commit:        c0f8e6675c62332263acdc7c3c2f61eca20bd60f
Parent:        4d2f9a4ff3fbfe4ee0df08478d81ea10f75823de
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 11 01:02:22 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 11 01:18:24 2022 +0200

make: generate

---
 man/pvdisplay.8_pregen | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/man/pvdisplay.8_pregen b/man/pvdisplay.8_pregen
index 23d41b29b..e7767d0c4 100644
--- a/man/pvdisplay.8_pregen
+++ b/man/pvdisplay.8_pregen
@@ -61,6 +61,8 @@ and more, using a more compact and configurable output format.
 .br
 [    \fB--readonly\fP ]
 .br
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.br
 [    \fB--separator\fP \fIString\fP ]
 .br
 [    \fB--shared\fP ]
@@ -320,6 +322,16 @@ device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
 .
 .HP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+.br
+Overrides current output format for reports which is defined globally by
+the report/output_format setting in \fBlvm.conf\fP(5).
+\fBbasic\fP is the original format with columns and rows.
+If there is more than one report per command, each report is prefixed
+with the report name for identification. \fBjson\fP produces report
+output in JSON format. See \fBlvmreport\fP(7) for more information.
+.
+.HP
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
 Select objects for processing and reporting based on specified criteria.

