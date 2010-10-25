From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:20 +0200
Subject: [PATCH 13/30] Eliminate uninitialized_var
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <0f16dc9e1e7859ac7a275bbd9218dda77bcabc7f.1287994530.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use some default value instead of a random number for unknown
minor_version.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/device/dev-md.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 89b9341..cb9feae 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -59,7 +59,7 @@ typedef enum {
 
 static uint64_t _v1_sb_offset(uint64_t size, md_minor_version_t minor_version)
 {
-	uint64_t uninitialized_var(sb_offset);
+	uint64_t sb_offset;
 
 	switch(minor_version) {
 	case MD_MINOR_V0:
@@ -69,6 +69,7 @@ static uint64_t _v1_sb_offset(uint64_t size, md_minor_version_t minor_version)
 		sb_offset = 0;
 		break;
 	case MD_MINOR_V2:
+	default:
 		sb_offset = 4 * 2;
 		break;
 	}
-- 
1.7.3.1


