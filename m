From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 10 Oct 2013 11:37:47 +0000 (UTC)
Subject: master - metadata: add INTERNAL_ERROR to "Metadata inconsistency" msg
Message-ID: <20131010113747.C0AE060D19@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6b35c70e8b17b09691d2db6ea2eadba2ee2d095d
Commit:        6b35c70e8b17b09691d2db6ea2eadba2ee2d095d
Parent:        029b8fbe767e63f1d0a4f6c81a0095af46e9a000
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Oct 10 13:34:43 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Oct 10 13:34:43 2013 +0200

metadata: add INTERNAL_ERROR to "Metadata inconsistency" msg

So we can spot it better if it occurs.
---
 lib/format_text/flags.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 6801d6c..a27b791 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -145,8 +145,8 @@ int print_flags(uint64_t status, int type, char *buffer, size_t size)
 		return 0;
 
 	if (status)
-		log_warn("Metadata inconsistency: Not all flags successfully "
-			 "exported.");
+		log_warn(INTERNAL_ERROR "Metadata inconsistency: "
+			 "Not all flags successfully exported.");
 
 	return 1;
 }


