From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 19 May 2020 09:38:44 +0000 (GMT)
Subject: stable-2.02 - build: make generate
Message-ID: <20200519093844.F182739540C4@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7ea50a47d15dea016f252a5940c6aa5c0d598bb6
Commit:        7ea50a47d15dea016f252a5940c6aa5c0d598bb6
Parent:        bac7d5951dd3b5b04d4532b342c1034802f0d466
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon May 11 18:01:15 2020 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue May 19 11:38:23 2020 +0200

build: make generate

---
 conf/example.conf.in | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 38855e933..29b0df497 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -326,6 +326,12 @@ devices {
 	# Enabling this setting allows the VG to be used as usual even with
 	# uncertain devices.
 	allow_changes_with_duplicate_pvs = 0
+
+	# Configuration option devices/allow_mixed_block_sizes.
+	# Allow PVs in the same VG with different logical block sizes.
+	# When allowed, the user is responsible to ensure that an LV is
+	# using PVs with matching block sizes when necessary.
+	allow_mixed_block_sizes = 1
 }
 
 # Configuration section allocation.


