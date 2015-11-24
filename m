From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 24 Nov 2015 10:33:10 +0000 (UTC)
Subject: master - libdm: drop extra space from cache target line
Message-ID: <20151124103310.9A090610DF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ddbf0075b1abb5ea0cb0ff56cc128fd18523ed36
Commit:        ddbf0075b1abb5ea0cb0ff56cc128fd18523ed36
Parent:        fe64d3a2e27cedd7973d0a01360796089596b20b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 23 23:12:43 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 23 23:33:37 2015 +0100

libdm: drop extra space from cache target line

Extra space between 'cache' target and metadata device caused
string comparation being not equal and thus always causing
table reload even when uneeded.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index dd1b0b6..49aa50f 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.112 - 
 =====================================
+  Drop extra space from cache target line to fix unneded table reloads.
 
 Version 1.02.111 - 23rd November 2015
 =====================================
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index d7e2143..830a6a8 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2429,7 +2429,7 @@ static int _cache_emit_segment_line(struct dm_task *dmt,
 	if (!_build_dev_string(origin, sizeof(origin), seg->origin))
 		return_0;
 
-	EMIT_PARAMS(pos, " %s %s %s", metadata, data, origin);
+	EMIT_PARAMS(pos, "%s %s %s", metadata, data, origin);
 
 	/* Data block size */
 	EMIT_PARAMS(pos, " %u", seg->data_block_size);


