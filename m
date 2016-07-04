From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  4 Jul 2016 15:42:02 +0000 (UTC)
Subject: master - tests: add mke2fs.conf
Message-ID: <20160704154202.0859360E3A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b91390c21149875c26f8c7b37e3cbdfda0f419ae
Commit:        b91390c21149875c26f8c7b37e3cbdfda0f419ae
Parent:        2981d1e79851bc83751efc1d9ce987cdc65305bc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 4 17:28:43 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 4 17:40:25 2016 +0200

tests: add mke2fs.conf

Add config for mkfs to get more predicatable results
when using mkfs across variety of distributions.

In future maybe use this per all tests as default.
For now user has to specify in a test MKE2FS_CONFIG envvar to use it.
---
 test/Makefile.in     |    1 +
 test/lib/mke2fs.conf |   45 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index f48d6ea..94b3105 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -205,6 +205,7 @@ install: .tests-stamp lib/paths-installed
 	$(INSTALL_DIR) $(DATADIR)/{shell,api,lib,dbus} $(EXECDIR)
 	$(INSTALL_DATA) shell/*.sh $(DATADIR)/shell
 	$(INSTALL_DATA) api/*.sh $(DATADIR)/api
+	$(INSTALL_DATA) lib/mke2fs.conf $(DATADIR)/lib
 	$(INSTALL_PROGRAM) api/*.{t,py} $(DATADIR)/api
 	$(INSTALL_PROGRAM) dbus/*.py $(DATADIR)/dbus/
 	$(INSTALL_DATA) lib/paths-installed $(DATADIR)/lib/paths
diff --git a/test/lib/mke2fs.conf b/test/lib/mke2fs.conf
new file mode 100644
index 0000000..81bed21
--- /dev/null
+++ b/test/lib/mke2fs.conf
@@ -0,0 +1,45 @@
+[defaults]
+	base_features = sparse_super,filetype,resize_inode,dir_index,ext_attr
+	enable_periodic_fsck = 1
+	blocksize = 4096
+	inode_size = 256
+	inode_ratio = 16384
+
+[fs_types]
+	ext3 = {
+		features = has_journal
+	}
+	ext4 = {
+		features = has_journal,extent,huge_file,flex_bg,dir_nlink,extra_isize
+		inode_size = 256
+	}
+	ext4dev = {
+		features = has_journal,extent,huge_file,flex_bg,dir_nlink,extra_isize
+		inode_size = 256
+		options = test_fs=1
+	}
+	small = {
+		blocksize = 1024
+		inode_size = 128
+		inode_ratio = 4096
+	}
+	floppy = {
+		blocksize = 1024
+		inode_size = 128
+		inode_ratio = 8192
+	}
+	news = {
+		inode_ratio = 4096
+	}
+	largefile = {
+		inode_ratio = 1048576
+		blocksize = -1
+	}
+	largefile4 = {
+		inode_ratio = 4194304
+		blocksize = -1
+	}
+	hurd = {
+	     blocksize = 4096
+	     inode_size = 128
+	}


