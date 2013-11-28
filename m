From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 28 Nov 2013 11:48:38 +0000 (UTC)
Subject: master - format-text: ensure aligment is not 0
Message-ID: <20131128114838.9D8D260F37@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=01c438a96c82bf31ccda0721707fc90afa01a07e
Commit:        01c438a96c82bf31ccda0721707fc90afa01a07e
Parent:        5a4137c804b0ba579c5f368fe91942c465815f66
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 24 19:00:53 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 28 12:42:39 2013 +0100

format-text: ensure aligment is not 0

Make sure this path of code is not used for alignment == 0,
to prevent division by 0.
---
 WHATS_NEW                     |    1 +
 lib/format_text/format-text.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 55b17c0..cd63144 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Check for non-zero aligment in _text_pv_add_metadata_area() to not div by 0.
   Add allocation/use_blkid_wiping to lvm.conf to enable blkid wiping.
   Add configure --enable-blkid_wiping to use libblkid to detect signatures.
   Add -W/--wipesignatures lvcreate option to support wiping on new LVs.
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 275d16f..eb5c9e9 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2083,7 +2083,7 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 			 * alignment since it would be useless.
 			 * Check first whether we can apply that!
 			 */
-			if (!pe_start_locked &&
+			if (!pe_start_locked && alignment &&
 			    ((limit - mda_start) > alignment * 2)) {
 				mda_size = limit - mda_start - alignment * 2;
 


