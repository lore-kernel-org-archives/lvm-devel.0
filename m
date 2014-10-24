From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:49 +0000 (UTC)
Subject: master - cleanup: use matching flags for permissions
Message-ID: <20141024144049.5A8B360CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9a6758e953a83aeb1d384df97c6f18b542c569a2
Commit:        9a6758e953a83aeb1d384df97c6f18b542c569a2
Parent:        37bd12e7ba60e5e6654d7edd912d011328401a21
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 24 13:07:02 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

cleanup: use matching flags for permissions

Since our status bits are 64b - use uint64_t for permissions.
---
 lib/metadata/metadata-exported.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 1af9cbf..cfc0ce2 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -856,7 +856,7 @@ struct lvcreate_params {
 	uint64_t pool_metadata_size; /* pools */
 	struct dm_list *pvh; /* all */
 
-	uint32_t permission; /* all */
+	uint64_t permission; /* all */
 	uint32_t read_ahead; /* all */
 	int approx_alloc;     /* all */
 	alloc_policy_t alloc; /* all */


