From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 4 Feb 2020 11:22:32 -0500
Subject: master - pvck: avoid memleak of vgname
Message-ID: <00627.120020411222701807@us-mta-218.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1bde35e596536abc176cb70506353476cd1705b1
Commit:        1bde35e596536abc176cb70506353476cd1705b1
Parent:        ac38b576f9f6daedf22a0d8472586bfe7de7c57e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 29 16:55:49 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 4 17:22:06 2020 +0100

pvck: avoid memleak of vgname

clang: no vgname buffer leak.
---
 tools/pvck.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 0266218..d57e026 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -788,7 +788,7 @@ static int _dump_current_text(struct device *dev,
 {
 	char *meta_buf;
 	struct dm_config_tree *cft;
-	const char *vgname = NULL;
+	char *vgname = NULL;
 	uint32_t crc;
 	uint32_t seqno = 0;
 	int mn = mda_num; /* 1 or 2 */
@@ -895,6 +895,7 @@ static int _dump_current_text(struct device *dev,
 
  out:
 	free(meta_buf);
+	free(vgname);
 	if (bad)
 		return 0;
 	return 1;



