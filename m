From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  4 Dec 2013 13:31:33 +0000 (UTC)
Subject: master - cleanup: size is already 64bit value
Message-ID: <20131204133133.675A960EB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=993831bdb15657b1fc6b9985cdaca9e3ccc1cfbc
Commit:        993831bdb15657b1fc6b9985cdaca9e3ccc1cfbc
Parent:        51783676fb8036832a08094fa34fd9458ee13711
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 9 13:18:43 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 4 14:30:25 2013 +0100

cleanup: size is already 64bit value

Cast is not needed.
---
 lib/metadata/metadata.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 61816e2..5f2addd 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -987,7 +987,7 @@ uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 		return 0;
 	}
 
-	return (uint64_t) size / extent_size;
+	return size / extent_size;
 }
 
 /*


