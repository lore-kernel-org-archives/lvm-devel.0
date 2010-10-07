From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu,  7 Oct 2010 16:06:37 +0200
Subject: [PATCH 7/9] Fix dry run of resize command
In-Reply-To: <cover.1286460218.git.zkabelac@redhat.com>
References: <cover.1286460218.git.zkabelac@redhat.com>
Message-ID: <58681d35062dd98e27190625f47606b1c6f157dc.1286460218.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Resolve from 'dry' position - we do not want to 'dry-run' echo command,
but resize of reiser fs in this case.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 scripts/fsadm.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 2ee24c9..79bac51 100644
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -301,7 +301,7 @@ resize_reiser() {
 	decode_size $1 $BLOCKSIZE
 	verbose "Resizing \"$VOLUME\" $BLOCKCOUNT -> $NEWBLOCKCOUNT blocks ($NEWSIZE bytes, bs: $NEWBLOCKCOUNT)"
 	if [ -n "$YES" ]; then
-		dry echo y | $RESIZE_REISER -s $NEWSIZE "$VOLUME"
+		echo y | dry $RESIZE_REISER -s $NEWSIZE "$VOLUME"
 	else
 		dry $RESIZE_REISER -s $NEWSIZE "$VOLUME"
 	fi
-- 
1.7.3.1


