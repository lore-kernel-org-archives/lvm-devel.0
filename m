From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 06 Oct 2010 14:54:14 +0200
Subject: [PATCH] Introduce MDA_IGNORABLE metadata status flag to differentiate ignorable mdas from other mdas
In-Reply-To: <4CAC5E5B.2080403@redhat.com>
References: <4CAC5E5B.2080403@redhat.com>
Message-ID: <4CAC7176.2070907@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Well, there's one more place where we need to set the flag.
(I need to look more thoroughly where else it's needed, hmm...)

Peter
---
 lib/format_text/text_label.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index e459cde..32934e7 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -216,7 +216,7 @@ int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *
 
 	mdal->ops = mda_lists->raw_ops;
 	mdal->metadata_locn = mdac;
-	mdal->status = 0;
+	mdal->status = MDA_IGNORABLE;
 
 	mdac->area.dev = dev;
 	mdac->area.start = start;


