From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Apr 2014 09:02:45 +0000 (UTC)
Subject: master - log: skip repeated hashing when logging once
Message-ID: <20140408090245.1889260268@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=700b4bfc9428d7440c018c0a5e9d9dcc3cc4cea1
Commit:        700b4bfc9428d7440c018c0a5e9d9dcc3cc4cea1
Parent:        96cf9dc0170d8a807ecac3956a80c3f51cfe48c0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 7 17:51:42 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 8 11:00:14 2014 +0200

log: skip repeated hashing when logging once

When a message is already found in the hash, no need to hash it again.
---
 lib/log/log.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index 194fdd3..a3c0139 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -268,7 +268,8 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 		if (_duplicated) {
 			if (dm_hash_lookup(_duplicated, message))
 				level = _LOG_NOTICE;
-			(void) dm_hash_insert(_duplicated, message, (void*)1);
+			else
+				(void) dm_hash_insert(_duplicated, message, (void*)1);
 		}
 	}
 


