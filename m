From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  1 Sep 2020 17:02:03 +0000 (GMT)
Subject: master - gcc: preserve constness of buffer
Message-ID: <20200901170203.1030B3951821@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=534760398c54aaa67144ddd7303456da8758674a
Commit:        534760398c54aaa67144ddd7303456da8758674a
Parent:        fd96f1014b11d073d775ea4777f3b3ba2eb93520
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Aug 29 22:02:41 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 1 17:57:50 2020 +0200

gcc: preserve constness of buffer

---
 tools/pvck.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index a0f567eeb..3895b7dd9 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -66,9 +66,9 @@ struct metadata_file {
 	char vgid_str[ID_STR_SIZE];
 };
 
-static char *_chars_to_str(void *in, void *out, int num, int max, const char *field)
+static char *_chars_to_str(const void *in, void *out, int num, int max, const char *field)
 {
-	char *i = in;
+	const char *i = in;
 	char *o = out;
 	int n;
 
@@ -95,10 +95,10 @@ static char *_chars_to_str(void *in, void *out, int num, int max, const char *fi
  * This is used to print mda_header.magic as a series of hex values
  * since it only contains some printable chars.
  */
-static char *_chars_to_hexstr(void *in, void *out, int num, int max, const char *field)
+static char *_chars_to_hexstr(const void *in, void *out, int num, int max, const char *field)
 {
 	char *tmp;
-	char *i = in;
+	const char *i = in;
 	int n;
 	int off = 0;
 	int ret;
@@ -732,7 +732,7 @@ static int _check_mda_header(struct mda_header *mh, int mda_num, uint64_t mda_of
 	}
 
 	if (memcmp(mh->magic, FMTT_MAGIC, sizeof(mh->magic))) {
-		log_print("CHECK: mda_header_%d.magic expected 0x%s", mda_num, _chars_to_hexstr((void *)&FMTT_MAGIC, str, 16, 256, "mda_header.magic"));
+		log_print("CHECK: mda_header_%d.magic expected 0x%s", mda_num, _chars_to_hexstr((const void *)&FMTT_MAGIC, str, 16, 256, "mda_header.magic"));
 		good_magic = 0;
 		bad++;
 	}


