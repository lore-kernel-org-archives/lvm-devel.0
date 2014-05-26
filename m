From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 26 May 2014 21:32:24 +0000 (UTC)
Subject: master - cleanup: internal error for impossible path
Message-ID: <20140526213224.EB6FB60DC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=49521f4e563fe0a19e70413f740e831f5fd16e16
Commit:        49521f4e563fe0a19e70413f740e831f5fd16e16
Parent:        965592340d04f02096b800107591290c1ad44443
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 23 23:53:04 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 26 22:57:28 2014 +0200

cleanup: internal error for impossible path

Add 'default' path for impossible execution code path.
---
 lib/device/dev-md.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index d6a7609..91cc322 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -60,7 +60,7 @@ typedef enum {
 
 static uint64_t _v1_sb_offset(uint64_t size, md_minor_version_t minor_version)
 {
-	uint64_t uninitialized_var(sb_offset);
+	uint64_t sb_offset;
 
 	switch(minor_version) {
 	case MD_MINOR_V0:
@@ -72,6 +72,10 @@ static uint64_t _v1_sb_offset(uint64_t size, md_minor_version_t minor_version)
 	case MD_MINOR_V2:
 		sb_offset = 4 * 2;
 		break;
+	default:
+		log_warn(INTERNAL_ERROR "WARNING: Unknown minor version %d.",
+			 minor_version);
+		return 0;
 	}
 	sb_offset <<= SECTOR_SHIFT;
 


