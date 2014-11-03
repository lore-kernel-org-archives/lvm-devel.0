From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:24:07 +0000 (UTC)
Subject: master - cleanup: consistent name
Message-ID: <20141103132407.BB3EB60E6E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fdc252ec35c8c08ef4674bb1656bf4bfed641add
Commit:        fdc252ec35c8c08ef4674bb1656bf4bfed641add
Parent:        ce7f06cf4e62147293678c0baf0c86c45e8b4549
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 31 11:52:30 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:34 2014 +0100

cleanup: consistent name

---
 tools/toollib.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.h b/tools/toollib.h
index 50cc26c..e0e1e66 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -115,7 +115,7 @@ int get_pool_params(struct cmd_context *cmd,
 		    const struct segment_type *segtype,
 		    int *passed_args,
 		    uint64_t *pool_metadata_size,
-		    int *pool_metadataspare,
+		    int *pool_metadata_spare,
 		    uint32_t *chunk_size,
 		    thin_discards_t *discards,
 		    int *zero);


