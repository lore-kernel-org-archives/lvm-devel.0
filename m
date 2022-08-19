From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 19 Aug 2022 12:58:47 +0000 (GMT)
Subject: main - vdo: reset errno before strtoull
Message-ID: <20220819125847.550513858CDA@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=309df239e3ee474f3a5337f8fa3c0a1f7b0a89e5
Commit:        309df239e3ee474f3a5337f8fa3c0a1f7b0a89e5
Parent:        ac2c78544fa60490f9506f4ea0cd7d74d2395b28
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 18 13:55:29 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 19 14:55:47 2022 +0200

vdo: reset errno before strtoull

Missed errno reset in commit ebad057579aeff0980a1b8af7eaacd56e62ed0c9.
---
 lib/metadata/vdo_manip.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index 637fd1e5d..0db401537 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -618,6 +618,7 @@ static int _get_memory_info(uint64_t *total_mb, uint64_t *available_mb)
 		if (!found)
 			continue; // not interesting
 
+		errno = 0;
 		*(found->value) = (uint64_t) strtoull(e, &tail, 10);
 
 		if ((e == tail) || errno)

