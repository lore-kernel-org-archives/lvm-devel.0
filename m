From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 27 Jul 2021 22:50:35 +0000 (GMT)
Subject: main - cov: dev-mpath: check config_wwids_file
Message-ID: <20210727225035.58EF8383B82C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b2db01b530e995a80abe3379019503a8cae72b10
Commit:        b2db01b530e995a80abe3379019503a8cae72b10
Parent:        b7edda8a98281b6eb400fe41f2498e031bce7ccf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 27 16:57:39 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 28 00:49:28 2021 +0200

cov: dev-mpath: check config_wwids_file

Since config_wwids_file is checked for NULL,
test is also before calling _read_wwid_file()
that is directly dereferencing it.
---
 lib/device/dev-mpath.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/device/dev-mpath.c b/lib/device/dev-mpath.c
index d3eaf42a3..ba7bf9740 100644
--- a/lib/device/dev-mpath.c
+++ b/lib/device/dev-mpath.c
@@ -124,7 +124,8 @@ int dev_mpath_init(const char *config_wwids_file)
 
 	_wwid_hash_tab = wwid_tab;
 
-	_read_wwid_file(config_wwids_file);
+	if (config_wwids_file)
+		_read_wwid_file(config_wwids_file);
 
 	return 1;
 }


