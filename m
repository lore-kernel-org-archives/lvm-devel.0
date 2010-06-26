From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 25 Jun 2010 22:52:32 -0400
Subject: [PATCH 01/38] Change 'filler' to 'flags' in on-disk 'raw_locn' structure.
In-Reply-To: <1277520789-6808-1-git-send-email-dwysocha@redhat.com>
References: <1277520789-6808-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1277520789-6808-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Future patches will make use of a specific flag in the on-disk 'raw_locn'
structure to enable/disable metadata areas, and facilitate metadata
balancing.

Note that 'filler' is always set to '0' (see add_mda() - memset),
so use of this area as a non-zero flags field is a safe way to
provide future code features.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_text/layout.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index b023e92..444a500 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -51,7 +51,7 @@ struct raw_locn {
 	uint64_t offset;	/* Offset in bytes to start sector */
 	uint64_t size;		/* Bytes */
 	uint32_t checksum;
-	uint32_t filler;
+	uint32_t flags;
 } __attribute__ ((packed));
 
 /* On disk */
-- 
1.6.0.6


