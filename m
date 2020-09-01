From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  1 Sep 2020 21:41:30 +0000 (GMT)
Subject: master - pvck: use array of bytes
Message-ID: <20200901214130.664E8386F823@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=66803586ef6d7ef7bcf4260b66e85ef2fa8c7022
Commit:        66803586ef6d7ef7bcf4260b66e85ef2fa8c7022
Parent:        1ff1e86debe29abc0ac706e5e7b89fc5192f191f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 1 21:08:12 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 1 23:40:24 2020 +0200

pvck: use array of bytes

Fix typo in use array of pointers instead of array of bytes.
This fixes 'break strict-aliasing rules' warning printed with older gcc.
---
 tools/pvck.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 3895b7dd9..73ef6ceff 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -2498,7 +2498,7 @@ fail:
 static int _update_mda(struct cmd_context *cmd, struct metadata_file *mf, struct device *dev,
 		       int mda_num, uint64_t mda_offset, uint64_t mda_size)
 {
-	char *buf[512];
+	char buf[512];
 	struct mda_header *mh;
 	struct raw_locn *rlocn0, *rlocn1;
 	uint64_t max_size;
@@ -2514,7 +2514,7 @@ static int _update_mda(struct cmd_context *cmd, struct metadata_file *mf, struct
 		goto fail;
 	}
 
-	if (!dev_read_bytes(dev, mda_offset, 512, buf)) {
+	if (!dev_read_bytes(dev, mda_offset, sizeof(buf), buf)) {
 		log_print("CHECK: failed to read mda_header_%d at %llu",
 			  mda_num, (unsigned long long)mda_offset);
 		goto fail;


