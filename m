From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  4 Dec 2014 08:18:24 +0000 (UTC)
Subject: master - pool: fix typo in error message: then -> than
Message-ID: <20141204081824.BE61660C26@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a5baf13a06fc509833803ee4c778bdf9b7f07399
Commit:        a5baf13a06fc509833803ee4c778bdf9b7f07399
Parent:        a057f40155b415be40dac31bb138ee66761ce999
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Dec 4 09:17:48 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Dec 4 09:18:16 2014 +0100

pool: fix typo in error message: then -> than

---
 lib/metadata/pool_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index ee32a3b..95b5867 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -402,7 +402,7 @@ int update_pool_params(const struct segment_type *segtype,
 			return_0;
 
 	if ((uint64_t) *chunk_size > (uint64_t) pool_data_extents * vg->extent_size) {
-		log_error("Size of %s data volume cannot be smaller then chunk size %s.",
+		log_error("Size of %s data volume cannot be smaller than chunk size %s.",
 			  segtype->name, display_size(vg->cmd, *chunk_size));
 		return 0;
 	}


