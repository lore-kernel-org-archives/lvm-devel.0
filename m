From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 26 Nov 2020 16:38:01 +0000 (GMT)
Subject: master - build: make generate
Message-ID: <20201126163801.38763396EC63@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=205fb35b50a14f10b95bb4a47935010efe6d96e8
Commit:        205fb35b50a14f10b95bb4a47935010efe6d96e8
Parent:        10a095a58b3c564d54ded4d59c2286546fc83b74
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Nov 26 17:37:32 2020 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Nov 26 17:37:32 2020 +0100

build: make generate

---
 conf/example.conf.in | 3 +--
 man/vgsplit.8_pregen | 7 ++++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 6b0622ab9..fe17942d9 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -937,8 +937,7 @@ global {
 	# a volume group's metadata, instead of always granting the read-only
 	# requests immediately, delay them to allow the read-write requests to
 	# be serviced. Without this setting, write access may be stalled by a
-	# high volume of read-only requests. This option only affects
-	# locking_type 1 viz. local file-based locking.
+	# high volume of read-only requests. This option only affects file locks.
 	prioritise_write_locks = 1
 
 	# Configuration option global/library_dir.
diff --git a/man/vgsplit.8_pregen b/man/vgsplit.8_pregen
index 3adb0510f..9731aa4fa 100644
--- a/man/vgsplit.8_pregen
+++ b/man/vgsplit.8_pregen
@@ -8,9 +8,10 @@ vgsplit - Move physical volumes into a new or existing volume group
     [ \fIoption_args\fP ]
 .br
 .SH DESCRIPTION
-vgsplit moves one or more PVs from a source VG to a destination VG. The
-PVs can be specified explicitly or implicitly by naming an LV, in which
-case on PVs underlying the LV are moved.
+vgsplit moves one or more PVs from a source VG (the first VG arg) to a
+destination VG (the second VG arg).  The PV(s) to move are named after the
+source and destination VGs, or an LV is named, in which case the PVs
+underlying the LV are moved.
 
 If the destination VG does not exist, a new VG is created (command options
 can be used to specify properties of the new VG, also see


