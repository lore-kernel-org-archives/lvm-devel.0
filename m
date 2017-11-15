From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 14 Nov 2017 20:05:57 -0500
Subject: master - regenerate man and conf
Message-ID: <201711150105.vAF15vLG000554@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fe63c09381103324c52cc380a80cef21b693e9db
Commit:        fe63c09381103324c52cc380a80cef21b693e9db
Parent:        02e987666540712a9467025bf36e46e041da2611
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Nov 15 01:05:07 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Nov 15 01:05:07 2017 +0000

regenerate man and conf

---
 conf/example.conf.in   |    4 +-
 man/lvconvert.8_pregen |   50 ++++++++++++++++++++++++------------------------
 2 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index b5b0e6a..aab274d 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -611,9 +611,9 @@ log {
 	# Select log messages by class.
 	# Some debugging messages are assigned to a class and only appear in
 	# debug output if the class is listed here. Classes currently
-	# available: memory, devices, activation, allocation, lvmetad,
+	# available: memory, devices, io, activation, allocation, lvmetad,
 	# metadata, cache, locking, lvmpolld. Use "all" to see everything.
-	debug_classes = [ "memory", "devices", "activation", "allocation", "lvmetad", "metadata", "cache", "locking", "lvmpolld", "dbus" ]
+	debug_classes = [ "memory", "devices", "io", "activation", "allocation", "lvmetad", "metadata", "cache", "locking", "lvmpolld", "dbus" ]
 }
 
 # Configuration section backup.
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index fb2d869..243d1c3 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -751,6 +751,31 @@ Merge COW snapshot LV into its origin.
 .br
 -
 
+Combine a former COW snapshot (second arg) with a former 
+.br
+origin LV (first arg) to reverse a splitsnapshot command.
+.br
+.P
+\fBlvconvert\fP \fB--type\fP \fBsnapshot\fP \fILV\fP \fILV\fP\fI_linear\fP
+.br
+.RS 4
+.ad l
+[ \fB-s\fP|\fB--snapshot\fP ]
+.ad b
+.br
+.ad l
+[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+[ COMMON_OPTIONS ]
+.RE
+.br
+-
+
 Replace failed PVs in a raid or mirror LV. 
 .br
 Repair a thin pool. 
@@ -1654,31 +1679,6 @@ Combine a former COW snapshot (second arg) with a former
 origin LV (first arg) to reverse a splitsnapshot command.
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBsnapshot\fP \fILV\fP \fILV\fP\fI_linear\fP
-.br
-.RS 4
-.ad l
-[ \fB-s\fP|\fB--snapshot\fP ]
-.ad b
-.br
-.ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
-.ad b
-.br
-.ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-[ COMMON_OPTIONS ]
-.RE
-.br
--
-
-Combine a former COW snapshot (second arg) with a former 
-.br
-origin LV (first arg) to reverse a splitsnapshot command.
-.br
-.P
 \fBlvconvert\fP \fB-s\fP|\fB--snapshot\fP \fILV\fP \fILV\fP\fI_linear\fP
 .br
 .RS 4


