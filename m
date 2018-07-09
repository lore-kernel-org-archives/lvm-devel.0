From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:34:22 -0400
Subject: master - build: install VDO small allocation profile
Message-ID: <201807091334.w69DYM4t030613@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c66a960149ae28f057bc1a91d6974e92fc572c30
Commit:        c66a960149ae28f057bc1a91d6974e92fc572c30
Parent:        d8a41f22e9a68b0424ee18b1859fb6369c712622
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 3 11:10:57 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:28:35 2018 +0200

build: install VDO small allocation profile

Profile shows all VDO configurables.

Usable with: lvcreate --metadataprofile vdo-small ...
---
 conf/Makefile.in       |    3 ++-
 conf/vdo-small.profile |   25 +++++++++++++++++++++++++
 2 files changed, 27 insertions(+), 1 deletions(-)

diff --git a/conf/Makefile.in b/conf/Makefile.in
index d47c759..e906835 100644
--- a/conf/Makefile.in
+++ b/conf/Makefile.in
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2018 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -25,6 +25,7 @@ PROFILES=$(PROFILE_TEMPLATES) \
 	$(srcdir)/cache-smq.profile \
 	$(srcdir)/thin-generic.profile \
 	$(srcdir)/thin-performance.profile \
+	$(srcdir)/vdo-small.profile \
 	$(srcdir)/lvmdbusd.profile
 
 include $(top_builddir)/make.tmpl
diff --git a/conf/vdo-small.profile b/conf/vdo-small.profile
new file mode 100644
index 0000000..0bd47b5
--- /dev/null
+++ b/conf/vdo-small.profile
@@ -0,0 +1,25 @@
+# Demo configuration for 'VDO' using less memory.
+#
+
+allocation {
+	vdo_use_compression = 1
+	vdo_use_deduplication = 1
+	vdo_emulate_512_sectors = 0
+	vdo_block_map_cache_size_mb = 128
+	vdo_block_map_period = 16380
+	vdo_check_point_frequency = 0
+	vdo_use_sparse_index = 0
+	vdo_index_memory_size_mb = 256
+	vdo_use_read_cache = 0
+	vdo_read_cache_size_mb = 0
+	vdo_slab_size_mb = 2048
+
+	vdo_ack_threads = 1
+	vdo_bio_threads = 1
+	vdo_bio_rotation = 64
+	vdo_cpu_threads = 2
+	vdo_hash_zone_threads = 1
+	vdo_logical_threads = 1
+	vdo_physical_threads = 1
+	vdo_write_policy = "auto"
+}


