From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 4 Mar 2020 07:25:46 -0500
Subject: stable-2.02 - Fix rounding writes up to sector size
Message-ID: <202003041225.024CPkxb004976@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=44c460954be5c63cf5338bd9151344fe2626565f
Commit:        44c460954be5c63cf5338bd9151344fe2626565f
Parent:        253d10f840682f85dad0e4c29f55ff50f94792fa
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 24 11:32:13 2019 -0500
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Mar 4 13:20:36 2020 +0100

Fix rounding writes up to sector size

Do this at two levels, although one would be enough to
fix the problem seen recently:

- Ignore any reported sector size other than 512 of 4096.
  If either sector size (physical or logical) is reported
  as 512, then use 512.  If neither are reported as 512,
  and one or the other is reported as 4096, then use 4096.
  If neither is reported as either 512 or 4096, then use 512.

- When rounding up a limited write in bcache to be a multiple
  of the sector size, check that the resulting write size is
  not larger than the bcache block itself.  (This shouldn't
  happen if the sector size is 512 or 4096.)

(cherry picked from commit 7550665ba49ac7d497d5b212e14b69298ef01361)

Conflicts:
	lib/device/dev-io.c
---
 lib/device/bcache.c | 89 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 87 insertions(+), 2 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index b64707ecc..77d1543c0 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -169,6 +169,7 @@ static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
 	sector_t offset;
 	sector_t nbytes;
 	sector_t limit_nbytes;
+	sector_t orig_nbytes;
 	sector_t extra_nbytes = 0;
 
 	if (((uintptr_t) data) & e->page_mask) {
@@ -191,11 +192,41 @@ static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
 			return false;
 		}
 
+		/*
+		 * If the bcache block offset+len goes beyond where lvm is
+		 * intending to write, then reduce the len being written
+		 * (which is the bcache block size) so we don't write past
+		 * the limit set by lvm.  If after applying the limit, the
+		 * resulting size is not a multiple of the sector size (512
+		 * or 4096) then extend the reduced size to be a multiple of
+		 * the sector size (we don't want to write partial sectors.)
+		 */
 		if (offset + nbytes > _last_byte_offset) {
 			limit_nbytes = _last_byte_offset - offset;
-			if (limit_nbytes % _last_byte_sector_size)
+
+			if (limit_nbytes % _last_byte_sector_size) {
 				extra_nbytes = _last_byte_sector_size - (limit_nbytes % _last_byte_sector_size);
 
+				/*
+				 * adding extra_nbytes to the reduced nbytes (limit_nbytes)
+				 * should make the final write size a multiple of the
+				 * sector size.  This should never result in a final size
+				 * larger than the bcache block size (as long as the bcache
+				 * block size is a multiple of the sector size).
+				 */
+				if (limit_nbytes + extra_nbytes > nbytes) {
+					log_warn("Skip extending write at %llu len %llu limit %llu extra %llu sector_size %llu",
+						 (unsigned long long)offset,
+						 (unsigned long long)nbytes,
+						 (unsigned long long)limit_nbytes,
+						 (unsigned long long)extra_nbytes,
+						 (unsigned long long)_last_byte_sector_size);
+					extra_nbytes = 0;
+				}
+			}
+
+			orig_nbytes = nbytes;
+
 			if (extra_nbytes) {
 				log_debug("Limit write at %llu len %llu to len %llu rounded to %llu",
 					  (unsigned long long)offset,
@@ -210,6 +241,22 @@ static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
 					  (unsigned long long)limit_nbytes);
 				nbytes = limit_nbytes;
 			}
+
+			/*
+			 * This shouldn't happen, the reduced+extended
+			 * nbytes value should never be larger than the
+			 * bcache block size.
+			 */
+			if (nbytes > orig_nbytes) {
+				log_error("Invalid adjusted write at %llu len %llu adjusted %llu limit %llu extra %llu sector_size %llu",
+					  (unsigned long long)offset,
+					  (unsigned long long)orig_nbytes,
+					  (unsigned long long)nbytes,
+					  (unsigned long long)limit_nbytes,
+					  (unsigned long long)extra_nbytes,
+					  (unsigned long long)_last_byte_sector_size);
+				return false;
+			}
 		}
 	}
 
@@ -403,6 +450,7 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 		uint64_t nbytes = len;
 		sector_t limit_nbytes = 0;
 		sector_t extra_nbytes = 0;
+		sector_t orig_nbytes = 0;
 
 		if (offset > _last_byte_offset) {
 			log_error("Limit write at %llu len %llu beyond last byte %llu",
@@ -415,9 +463,30 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 
 		if (offset + nbytes > _last_byte_offset) {
 			limit_nbytes = _last_byte_offset - offset;
-			if (limit_nbytes % _last_byte_sector_size)
+
+			if (limit_nbytes % _last_byte_sector_size) {
 				extra_nbytes = _last_byte_sector_size - (limit_nbytes % _last_byte_sector_size);
 
+				/*
+				 * adding extra_nbytes to the reduced nbytes (limit_nbytes)
+				 * should make the final write size a multiple of the
+				 * sector size.  This should never result in a final size
+				 * larger than the bcache block size (as long as the bcache
+				 * block size is a multiple of the sector size).
+				 */
+				if (limit_nbytes + extra_nbytes > nbytes) {
+					log_warn("Skip extending write at %llu len %llu limit %llu extra %llu sector_size %llu",
+						 (unsigned long long)offset,
+						 (unsigned long long)nbytes,
+						 (unsigned long long)limit_nbytes,
+						 (unsigned long long)extra_nbytes,
+						 (unsigned long long)_last_byte_sector_size);
+					extra_nbytes = 0;
+				}
+			}
+
+			orig_nbytes = nbytes;
+
 			if (extra_nbytes) {
 				log_debug("Limit write at %llu len %llu to len %llu rounded to %llu",
 					  (unsigned long long)offset,
@@ -432,6 +501,22 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 					  (unsigned long long)limit_nbytes);
 				nbytes = limit_nbytes;
 			}
+
+			/*
+			 * This shouldn't happen, the reduced+extended
+			 * nbytes value should never be larger than the
+			 * bcache block size.
+			 */
+			if (nbytes > orig_nbytes) {
+				log_error("Invalid adjusted write at %llu len %llu adjusted %llu limit %llu extra %llu sector_size %llu",
+					  (unsigned long long)offset,
+					  (unsigned long long)orig_nbytes,
+					  (unsigned long long)nbytes,
+					  (unsigned long long)limit_nbytes,
+					  (unsigned long long)extra_nbytes,
+					  (unsigned long long)_last_byte_sector_size);
+				return false;
+			}
 		}
 
 		where = offset;



