From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 25 Feb 2016 22:36:30 +0000 (UTC)
Subject: master - cleanup: indent
Message-ID: <20160225223630.3432E602B1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e9b523e3044b83fc1a919f8a07a85d169c7d4d55
Commit:        e9b523e3044b83fc1a919f8a07a85d169c7d4d55
Parent:        5c29b54d4dbf0a94525172f5526fd5ff7996de48
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 25 16:50:22 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 25 23:30:25 2016 +0100

cleanup: indent

Last update missed to indent params.
---
 lib/metadata/pv_manip.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 48706d1..d38262d 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -757,10 +757,10 @@ static int pvremove_check(struct cmd_context *cmd, const char *name,
 
 	if (force_count)
 		log_warn("WARNING: Wiping physical volume label from "
-			  "%s%s%s%s", name,
-			  !is_orphan(pv) ? " of volume group \"" : "",
-			  pv_vg_name(pv),
-			  !is_orphan(pv) ? "\"" : "");
+			 "%s%s%s%s", name,
+			 !is_orphan(pv) ? " of volume group \"" : "",
+			 pv_vg_name(pv),
+			 !is_orphan(pv) ? "\"" : "");
 
 	r = 1;
 bad:


