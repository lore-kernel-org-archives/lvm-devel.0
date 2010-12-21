From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:41:33 +0100
Subject: [PATCH 01/23] Remove dead assignment to thisfd
In-Reply-To: <cover.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
Message-ID: <a63e4321bd2f0a7919a7eaaa1696e3f1094ad1bf.1292945707.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Value 'thisfd' is not read again after this assigment.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 1a35c49..a6839f4 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -827,7 +827,6 @@ static void main_loop(int local_sock, int cmd_timeout)
 					struct local_client *free_fd;
 					lastfd->next = thisfd->next;
 					free_fd = thisfd;
-					thisfd = lastfd;
 
 					DEBUGLOG("removeme set for fd %d\n", free_fd->fd);
 
@@ -863,7 +862,6 @@ static void main_loop(int local_sock, int cmd_timeout)
 							 ret, errno);
 						lastfd->next = thisfd->next;
 						free_fd = thisfd;
-						thisfd = lastfd;
 						safe_close(&(free_fd->fd));
 
 						/* Queue cleanup, this also frees the client struct */
-- 
1.7.3.4


