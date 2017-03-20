From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 20 Mar 2017 18:04:52 -0400
Subject: master - lvcreate: continue to accept --thinpool with -L and -V but not -T
Message-ID: <201703202204.v2KM4qW2012946@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=642d682d8ddcc3152f68b3ec8518902a0ef448ac
Commit:        642d682d8ddcc3152f68b3ec8518902a0ef448ac
Parent:        b3e833c777f46c0c3b3ef70c94cd0fb808be0a50
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Mar 20 21:57:17 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Mar 20 22:04:37 2017 +0000

lvcreate: continue to accept --thinpool with -L and -V but not -T

lvcreate --thinpool POOL1 -L 100M --virtualsize 100M snapper_thinp

https://bugzilla.redhat.com/1434027

(The general rule is that a command is accepted if it is unambiguous.
The combination -L -V --thinpool uniquely identifies the operation.)
---
 tools/command-lines.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 2fec553..a4d1f38 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1056,7 +1056,7 @@ FLAGS: SECONDARY_SYNTAX
 ---
 
 lvcreate --size SizeMB --virtualsize SizeMB VG
-OO: --type thin, --type snapshot, --thin, --snapshot, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
+OO: --type thin, --type snapshot, --thin, --snapshot, --thinpool LV_new, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
 IO: --mirrors 0


