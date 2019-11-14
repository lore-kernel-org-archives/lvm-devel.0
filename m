From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Nov 2019 12:07:34 -0500
Subject: master - pvck: check result of dev_get_size
Message-ID: <94077.119111412073000869@us-mta-361.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1f4968289c9c0e2a1e850317ef173df11938b7f3
Commit:        1f4968289c9c0e2a1e850317ef173df11938b7f3
Parent:        d67ce9e140b5691a3f75a69d6e735eec30603670
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 14 17:32:22 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 14 18:06:42 2019 +0100

pvck: check result of dev_get_size

Don't use garbage value for later computations.
---
 tools/pvck.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index c197a97..c9692b0 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -1468,7 +1468,8 @@ static int _dump_search(struct cmd_context *cmd,
 		uint64_t dev_bytes;
 		uint64_t extra_bytes;
 
-		dev_get_size(dev, &dev_sectors);
+		if (!dev_get_size(dev, &dev_sectors))
+			return_ECMD_FAILED;
 
 		dev_bytes = dev_sectors * 512;
 		extra_bytes = dev_bytes % ONE_MB_IN_BYTES;



