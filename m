From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 20 Sep 2018 09:48:41 -0400
Subject: master - [radix-tree] Fix bug in _dump
Message-ID: <201809201348.w8KDmf15008564@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0ac7913c6a43c5bcfbba735652041a0eae4180c6
Commit:        0ac7913c6a43c5bcfbba735652041a0eae4180c6
Parent:        abe2210c261223212435fbfd505842583ee1145a
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu Sep 20 14:18:57 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Sep 20 14:18:57 2018 +0100

[radix-tree] Fix bug in _dump

Values in an n48 were not being printed in the correct order.
---
 base/data-struct/radix-tree-adaptive.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/base/data-struct/radix-tree-adaptive.c b/base/data-struct/radix-tree-adaptive.c
index 233bebd..a657b2b 100644
--- a/base/data-struct/radix-tree-adaptive.c
+++ b/base/data-struct/radix-tree-adaptive.c
@@ -1260,9 +1260,10 @@ static void _dump(FILE *out, struct value v, unsigned indent)
 				fprintf(out, "%x ", i);
 		fprintf(out, ">\n");
 
-		for (i = 0; i < 256; i++)
-			if (n48->keys[i] < 48)
-				_dump(out, n48->values[i], indent + 1);
+		for (i = 0; i < n48->nr_entries; i++) {
+			assert(n48->values[i].type != UNSET);
+			_dump(out, n48->values[i], indent + 1);
+		}
 		break;
 
 	case NODE256:


