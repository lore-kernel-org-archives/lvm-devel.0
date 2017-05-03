From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 3 May 2017 06:30:22 -0400
Subject: master - man: generate
Message-ID: <201705031030.v43AUMnw017446@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6bdbb283d54c7f91abd75c0c463a8475ac5435ff
Commit:        6bdbb283d54c7f91abd75c0c463a8475ac5435ff
Parent:        a0f742542f5762c4c80e52eab31819ea5abdb94b
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed May 3 11:23:15 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed May 3 11:23:15 2017 +0100

man: generate

---
 man/lvchange.8_pregen       |    2 +-
 man/lvconvert.8_pregen      |    2 +-
 man/lvcreate.8_pregen       |    2 +-
 man/lvdisplay.8_pregen      |    2 +-
 man/lvextend.8_pregen       |    2 +-
 man/lvm-fullreport.8_pregen |    2 +-
 man/lvm-lvpoll.8_pregen     |    2 +-
 man/lvmconfig.8_pregen      |    2 +-
 man/lvmdiskscan.8_pregen    |    2 +-
 man/lvreduce.8_pregen       |    2 +-
 man/lvremove.8_pregen       |    2 +-
 man/lvrename.8_pregen       |    2 +-
 man/lvresize.8_pregen       |    2 +-
 man/lvs.8_pregen            |    2 +-
 man/lvscan.8_pregen         |    2 +-
 man/pvchange.8_pregen       |    2 +-
 man/pvck.8_pregen           |    2 +-
 man/pvcreate.8_pregen       |    2 +-
 man/pvdisplay.8_pregen      |    2 +-
 man/pvmove.8_pregen         |    2 +-
 man/pvremove.8_pregen       |    2 +-
 man/pvresize.8_pregen       |    2 +-
 man/pvs.8_pregen            |    2 +-
 man/pvscan.8_pregen         |    2 +-
 man/vgcfgbackup.8_pregen    |    2 +-
 man/vgcfgrestore.8_pregen   |    2 +-
 man/vgchange.8_pregen       |    2 +-
 man/vgck.8_pregen           |    2 +-
 man/vgconvert.8_pregen      |    2 +-
 man/vgcreate.8_pregen       |    2 +-
 man/vgdisplay.8_pregen      |    2 +-
 man/vgexport.8_pregen       |    2 +-
 man/vgextend.8_pregen       |    2 +-
 man/vgimport.8_pregen       |    2 +-
 man/vgimportclone.8_pregen  |    2 +-
 man/vgmerge.8_pregen        |    2 +-
 man/vgmknodes.8_pregen      |    2 +-
 man/vgreduce.8_pregen       |    2 +-
 man/vgremove.8_pregen       |    2 +-
 man/vgrename.8_pregen       |    2 +-
 man/vgs.8_pregen            |    2 +-
 man/vgscan.8_pregen         |    2 +-
 man/vgsplit.8_pregen        |    2 +-
 43 files changed, 43 insertions(+), 43 deletions(-)

diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index 174ad32..e89ad39 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -913,7 +913,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 3652303..3a96dc8 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -1178,7 +1178,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index 38edc85..3954026 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -1301,7 +1301,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/lvdisplay.8_pregen b/man/lvdisplay.8_pregen
index 49de9cf..a0ca9aa 100644
--- a/man/lvdisplay.8_pregen
+++ b/man/lvdisplay.8_pregen
@@ -349,7 +349,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/lvextend.8_pregen b/man/lvextend.8_pregen
index 46f1db4..ae631be 100644
--- a/man/lvextend.8_pregen
+++ b/man/lvextend.8_pregen
@@ -484,7 +484,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/lvm-fullreport.8_pregen b/man/lvm-fullreport.8_pregen
index 11ba4b8..8104dba 100644
--- a/man/lvm-fullreport.8_pregen
+++ b/man/lvm-fullreport.8_pregen
@@ -331,7 +331,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/lvm-lvpoll.8_pregen b/man/lvm-lvpoll.8_pregen
index b99a45d..1292a6c 100644
--- a/man/lvm-lvpoll.8_pregen
+++ b/man/lvm-lvpoll.8_pregen
@@ -174,7 +174,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/lvmconfig.8_pregen b/man/lvmconfig.8_pregen
index e6d34aa..e7f93cd 100644
--- a/man/lvmconfig.8_pregen
+++ b/man/lvmconfig.8_pregen
@@ -269,7 +269,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/lvmdiskscan.8_pregen b/man/lvmdiskscan.8_pregen
index 4e390d5..b346fde 100644
--- a/man/lvmdiskscan.8_pregen
+++ b/man/lvmdiskscan.8_pregen
@@ -143,7 +143,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/lvreduce.8_pregen b/man/lvreduce.8_pregen
index 1781600..65f3da4 100644
--- a/man/lvreduce.8_pregen
+++ b/man/lvreduce.8_pregen
@@ -222,7 +222,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/lvremove.8_pregen b/man/lvremove.8_pregen
index 5edb4ef..cc28563 100644
--- a/man/lvremove.8_pregen
+++ b/man/lvremove.8_pregen
@@ -203,7 +203,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/lvrename.8_pregen b/man/lvrename.8_pregen
index de41077..dfb9247 100644
--- a/man/lvrename.8_pregen
+++ b/man/lvrename.8_pregen
@@ -163,7 +163,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/lvresize.8_pregen b/man/lvresize.8_pregen
index 3e12aa2..df9d93c 100644
--- a/man/lvresize.8_pregen
+++ b/man/lvresize.8_pregen
@@ -426,7 +426,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/lvs.8_pregen b/man/lvs.8_pregen
index 31244e2..b16bc86 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -345,7 +345,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/lvscan.8_pregen b/man/lvscan.8_pregen
index 12211b2..523de90 100644
--- a/man/lvscan.8_pregen
+++ b/man/lvscan.8_pregen
@@ -190,7 +190,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/pvchange.8_pregen b/man/pvchange.8_pregen
index 62f909f..85ffcc8 100644
--- a/man/pvchange.8_pregen
+++ b/man/pvchange.8_pregen
@@ -264,7 +264,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/pvck.8_pregen b/man/pvck.8_pregen
index 0d7924c..fe5a030 100644
--- a/man/pvck.8_pregen
+++ b/man/pvck.8_pregen
@@ -136,7 +136,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/pvcreate.8_pregen b/man/pvcreate.8_pregen
index 55d153f..d3cb688 100644
--- a/man/pvcreate.8_pregen
+++ b/man/pvcreate.8_pregen
@@ -294,7 +294,7 @@ on the ability to use vgsplit later.)
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/pvdisplay.8_pregen b/man/pvdisplay.8_pregen
index 94d6ebf..9434508 100644
--- a/man/pvdisplay.8_pregen
+++ b/man/pvdisplay.8_pregen
@@ -334,7 +334,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/pvmove.8_pregen b/man/pvmove.8_pregen
index e6aa48f..08f35b9 100644
--- a/man/pvmove.8_pregen
+++ b/man/pvmove.8_pregen
@@ -268,7 +268,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/pvremove.8_pregen b/man/pvremove.8_pregen
index 57b28cf..a913ab3 100644
--- a/man/pvremove.8_pregen
+++ b/man/pvremove.8_pregen
@@ -144,7 +144,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/pvresize.8_pregen b/man/pvresize.8_pregen
index 1b37c72..8a03088 100644
--- a/man/pvresize.8_pregen
+++ b/man/pvresize.8_pregen
@@ -132,7 +132,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/pvs.8_pregen b/man/pvs.8_pregen
index d0742df..9b5162a 100644
--- a/man/pvs.8_pregen
+++ b/man/pvs.8_pregen
@@ -332,7 +332,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/pvscan.8_pregen b/man/pvscan.8_pregen
index 472728c..0148c09 100644
--- a/man/pvscan.8_pregen
+++ b/man/pvscan.8_pregen
@@ -327,7 +327,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/vgcfgbackup.8_pregen b/man/vgcfgbackup.8_pregen
index d085a34..6a7099d 100644
--- a/man/vgcfgbackup.8_pregen
+++ b/man/vgcfgbackup.8_pregen
@@ -185,7 +185,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/vgcfgrestore.8_pregen b/man/vgcfgrestore.8_pregen
index 5197f1a..d15859e 100644
--- a/man/vgcfgrestore.8_pregen
+++ b/man/vgcfgrestore.8_pregen
@@ -284,7 +284,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index d3514b9..6d95335 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -817,7 +817,7 @@ on the ability to use vgsplit later.)
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/vgck.8_pregen b/man/vgck.8_pregen
index fa47193..235c3cc 100644
--- a/man/vgck.8_pregen
+++ b/man/vgck.8_pregen
@@ -132,7 +132,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/vgconvert.8_pregen b/man/vgconvert.8_pregen
index ef524fe..60b474b 100644
--- a/man/vgconvert.8_pregen
+++ b/man/vgconvert.8_pregen
@@ -215,7 +215,7 @@ on the ability to use vgsplit later.)
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/vgcreate.8_pregen b/man/vgcreate.8_pregen
index d65d4e2..6311e42 100644
--- a/man/vgcreate.8_pregen
+++ b/man/vgcreate.8_pregen
@@ -367,7 +367,7 @@ on the ability to use vgsplit later.)
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/vgdisplay.8_pregen b/man/vgdisplay.8_pregen
index a9a9463..9b99936 100644
--- a/man/vgdisplay.8_pregen
+++ b/man/vgdisplay.8_pregen
@@ -323,7 +323,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/vgexport.8_pregen b/man/vgexport.8_pregen
index ee69731..6d2c6ca 100644
--- a/man/vgexport.8_pregen
+++ b/man/vgexport.8_pregen
@@ -160,7 +160,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/vgextend.8_pregen b/man/vgextend.8_pregen
index 23d83c9..5445f6c 100644
--- a/man/vgextend.8_pregen
+++ b/man/vgextend.8_pregen
@@ -258,7 +258,7 @@ on the ability to use vgsplit later.)
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/vgimport.8_pregen b/man/vgimport.8_pregen
index 138a239..ffd237c 100644
--- a/man/vgimport.8_pregen
+++ b/man/vgimport.8_pregen
@@ -168,7 +168,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/vgimportclone.8_pregen b/man/vgimportclone.8_pregen
index 3c5245e..ea326f7 100644
--- a/man/vgimportclone.8_pregen
+++ b/man/vgimportclone.8_pregen
@@ -153,7 +153,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/vgmerge.8_pregen b/man/vgmerge.8_pregen
index 8705d76..c2a071b 100644
--- a/man/vgmerge.8_pregen
+++ b/man/vgmerge.8_pregen
@@ -146,7 +146,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/vgmknodes.8_pregen b/man/vgmknodes.8_pregen
index 5bfd1a8..d23ecaf 100644
--- a/man/vgmknodes.8_pregen
+++ b/man/vgmknodes.8_pregen
@@ -151,7 +151,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/vgreduce.8_pregen b/man/vgreduce.8_pregen
index 98a2278..d5cdac3 100644
--- a/man/vgreduce.8_pregen
+++ b/man/vgreduce.8_pregen
@@ -267,7 +267,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/vgremove.8_pregen b/man/vgremove.8_pregen
index 8ede805..22e778c 100644
--- a/man/vgremove.8_pregen
+++ b/man/vgremove.8_pregen
@@ -163,7 +163,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/vgrename.8_pregen b/man/vgrename.8_pregen
index 0dd21d4..5a5b8fa 100644
--- a/man/vgrename.8_pregen
+++ b/man/vgrename.8_pregen
@@ -174,7 +174,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/vgs.8_pregen b/man/vgs.8_pregen
index b621666..7909af9 100644
--- a/man/vgs.8_pregen
+++ b/man/vgs.8_pregen
@@ -327,7 +327,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/vgscan.8_pregen b/man/vgscan.8_pregen
index df36e3a..ccc2f29 100644
--- a/man/vgscan.8_pregen
+++ b/man/vgscan.8_pregen
@@ -171,7 +171,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
diff --git a/man/vgsplit.8_pregen b/man/vgsplit.8_pregen
index 98235ea..400cdcd 100644
--- a/man/vgsplit.8_pregen
+++ b/man/vgsplit.8_pregen
@@ -244,7 +244,7 @@ on the command.
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
+Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l


