From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:38 +0000 (UTC)
Subject: master - toolib: early validation of chunk size
Message-ID: <20141006133338.CA88D61041@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a0693da97f6873b08d33f8c44baacde77e28e33a
Commit:        a0693da97f6873b08d33f8c44baacde77e28e33a
Parent:        59ced3c28186e6d45e2e8374b04e32256f636a82
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 4 22:36:41 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:23:07 2014 +0200

toolib: early validation of chunk size

Since we now have validate_pool_chunk_size() we could
validate entered values directly prior openning vg.
---
 tools/toollib.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 69c1c39..ddd669a 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1257,6 +1257,10 @@ int get_pool_params(struct cmd_context *cmd,
 
 		*passed_args |= PASS_ARG_CHUNK_SIZE;
 		*chunk_size = arg_uint_value(cmd, chunksize_ARG, 0);
+
+		if (!validate_pool_chunk_size(cmd, segtype, *chunk_size))
+			return_0;
+
 		log_very_verbose("Setting pool chunk size: %s",
 				 display_size(cmd, *chunk_size));
 	}


