From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  6 Mar 2015 13:31:33 +0000 (UTC)
Subject: master - lib: zero returned labeller struct
Message-ID: <20150306133133.9196E606F1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4d16bfaabb5d72009e80cb6f5bc0d650101ebb33
Commit:        4d16bfaabb5d72009e80cb6f5bc0d650101ebb33
Parent:        6f68f4364b537cf52a27b5e53bb7f10de5a938fe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 6 08:42:20 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 6 13:17:39 2015 +0100

lib: zero returned labeller struct

Return zeroed struct.
(Structure will be extended, so ensure all members are initilized.)
---
 lib/format_text/text_label.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 516d694..e451be4 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -465,7 +465,7 @@ struct labeller *text_labeller_create(const struct format_type *fmt)
 {
 	struct labeller *l;
 
-	if (!(l = dm_malloc(sizeof(*l)))) {
+	if (!(l = dm_zalloc(sizeof(*l)))) {
 		log_error("Couldn't allocate labeller object.");
 		return NULL;
 	}


