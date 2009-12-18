From: Milan Broz <mbroz@redhat.com>
Date: Fri, 18 Dec 2009 13:23:21 +0100
Subject: [PATCH] Drop metadata cache after device was autorepared and removed from VG.
Message-ID: <1261139001-17456-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

All long running processes must reload metadata when some
device becomes orphan after repair.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/metadata.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c4a0332..f2ff8ac 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2794,6 +2794,9 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				vg_release(correct_vg);
 				return_NULL;
 			}
+
+			/* Refresh metadata after orphan write */
+			drop_cached_metadata(correct_vg);
       next_pv:
 			;
 		}
-- 
1.6.5.4


