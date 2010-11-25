From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:20 +0100
Subject: [PATCH 16/29] Test uuid for NULL
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <fc1d0eaa750c2123a16edbb58b417889a5130141.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This one again makes static analysis easier.

Though in this case when uuid is NULL len is also 0 so no bytes are
copied from the src address so no dereference happens - the function
memcpy itself is declared as the function which doesn't take
NULL as either src or dst parameter - let's be complaint.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/dmsetup.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 241fa74..1a56d24 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -343,7 +343,9 @@ static char *_extract_uuid_prefix(const char *uuid, const int separator)
 		return NULL;
 	}
 
-	memcpy(uuid_prefix, uuid, len);
+	if (uuid)
+		memcpy(uuid_prefix, uuid, len);
+
 	uuid_prefix[len] = '\0';
 
 	return uuid_prefix;
-- 
1.7.3.2


