From: David Teigland <teigland@sourceware.org>
Date: Tue, 27 Oct 2020 19:32:51 +0000 (GMT)
Subject: master - pvck: handle first mda at non-4096 offset
Message-ID: <20201027193251.3592C3954085@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c96645781ceb88c625dfae73e5baa08f1ce0e07e
Commit:        c96645781ceb88c625dfae73e5baa08f1ce0e07e
Parent:        020d1edaa06e5e05b58e8d39530408f86a22d1b8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 27 14:28:54 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Oct 27 14:28:54 2020 -0500

pvck: handle first mda at non-4096 offset

It's possible for a machine with a non-4k page size
to create a PV with an mda_header at an offset other
than 4k.  Fix pvck --dump to work with these other
mda offsets.  pvck --repair will write a new first
mda at 4096 but lvm with other page sizes will work
with this.
---
 tools/pvck.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 7ae4976e5..39692e3de 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -1406,9 +1406,10 @@ static int _dump_headers(struct cmd_context *cmd, const char *dump, struct setti
 	}
 
 	/*
-	 * The first mda is always 4096 bytes from the start of the device.
+	 * The first mda is usually 4096 bytes from the start of the device.
+	 * (If created by a machine with larger pages it could be 8k/16k/64k.)
 	 */
-	if (!_dump_mda_header(cmd, set, 1, 0, 0, NULL, dev, def, 4096, mda1_size, &mda1_checksum, NULL))
+	if (!_dump_mda_header(cmd, set, 1, 0, 0, NULL, dev, def, mda1_offset, mda1_size, &mda1_checksum, NULL))
 		bad++;
 
 	if (mda2_offset) {
@@ -1463,7 +1464,7 @@ static int _dump_metadata(struct cmd_context *cmd, const char *dump, struct sett
 	 * The first mda is always 4096 bytes from the start of the device.
 	 */
 	if (mda_num == 1) {
-		if (!_dump_mda_header(cmd, set, 0, print_metadata, print_area, tofile, dev, def, 4096, mda1_size, &mda1_checksum, NULL))
+		if (!_dump_mda_header(cmd, set, 0, print_metadata, print_area, tofile, dev, def, mda1_offset, mda1_size, &mda1_checksum, NULL))
 			bad++;
 	} else if (mda_num == 2) {
 		if (!mda2_offset) {
@@ -1497,7 +1498,7 @@ static int _dump_found(struct cmd_context *cmd, struct settings *set, uint64_t l
 		bad++;
 
 	if (found_label && mda1_offset) {
-		if (!_dump_mda_header(cmd, set, 0, 0, 0, NULL, dev, NULL, 4096, mda1_size, &mda1_checksum, &found_header1))
+		if (!_dump_mda_header(cmd, set, 0, 0, 0, NULL, dev, NULL, mda1_offset, mda1_size, &mda1_checksum, &found_header1))
 			bad++;
 	}
 
@@ -1681,7 +1682,7 @@ static int _dump_search(struct cmd_context *cmd, const char *dump, struct settin
 	 */
 	if ((mda_num == 1) && found_label && mda1_offset && mda1_size) {
 		/* use header values when available */
-		mda_offset = 4096;
+		mda_offset = mda1_offset;
 		mda_size = mda1_size;
 
 	} else if (mda_num == 1) {


