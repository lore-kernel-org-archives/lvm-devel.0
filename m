From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 21 Sep 2021 19:51:07 +0000 (GMT)
Subject: main - cov: sanitize function environment
Message-ID: <20210921195107.503A73858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=30e27d2f8b8fbe3031c0e2863a22c77b577019a0
Commit:        30e27d2f8b8fbe3031c0e2863a22c77b577019a0
Parent:        a13dfcbc77bcfdb4bfcff659fde8e11f73225643
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 21 18:46:52 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 21 21:03:47 2021 +0200

cov: sanitize function environment

Coverity can see that function is either used with 'dev' or 'def'.
---
 tools/pvck.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/tools/pvck.c b/tools/pvck.c
index 0d1bc1b17..b96b1c784 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -379,6 +379,9 @@ static bool _read_bytes(struct device *dev, struct devicefile *def, uint64_t sta
 	if (dev)
 		return dev_read_bytes(dev, start, len, data);
 
+	if (!def)
+		return false;
+
 	off = lseek(def->fd, start, SEEK_SET);
 	if (off != start)
 		return false;


