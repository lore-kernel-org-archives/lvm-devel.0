From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon, 18 Jan 2021 13:46:38 +0000 (GMT)
Subject: main - make: generate
Message-ID: <20210118134638.D0B21386F47D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9757b4726c6f1e16c84210a3c4578db29eb7662d
Commit:        9757b4726c6f1e16c84210a3c4578db29eb7662d
Parent:        37227b8ad6ba67804f98cdadd0ed6f2b369ae656
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Jan 18 14:46:22 2021 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Jan 18 14:46:22 2021 +0100

make: generate

---
 man/lvconvert.8_pregen | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index a47ccac08..170eec815 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -772,6 +772,10 @@ Add a cache to an LV, using a specified cache device.
 .br
 .RS 4
 .ad l
+[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+.ad b
+.br
+.ad l
 [    \fB--cachesize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br


