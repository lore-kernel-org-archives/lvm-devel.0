From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:41:39 +0100
Subject: [PATCH 07/23] Move lastfd handling into for()
In-Reply-To: <cover.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
Message-ID: <403be35b0f1d1d1da149e3d9a948a6416475287e.1292945707.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

WARNING - unclear code.

The loop inside for() works with assumption lastfd would be defined
when internal 'if' branches are taken.

Patch adds check for the case lastfd was not yet defined - i.e. removeme
of the first element in the list (code itself should be probably switched
to standard dm_list?)

>From the code reading it's not quite clear how the code should work and
if the case could actually ever happen.

As I'm not familiar with CLVMD logic here - it's probably for someone with
better knowledge to decide what is the right step here.

Other solution could be - to check 'lastfd' before if() and continue for
the first loop - i.e. expecting at least 2 members in list ?

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 7bb28a3..fa5a726 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -826,7 +826,8 @@ static void main_loop(int local_sock, int cmd_timeout)
 
 				if (thisfd->removeme) {
 					struct local_client *free_fd;
-					lastfd->next = thisfd->next;
+					if (lastfd)
+						lastfd->next = thisfd->next;
 					free_fd = thisfd;
 
 					DEBUGLOG("removeme set for fd %d\n", free_fd->fd);
@@ -861,7 +862,8 @@ static void main_loop(int local_sock, int cmd_timeout)
 
 						DEBUGLOG("ret == %d, errno = %d. removing client\n",
 							 ret, errno);
-						lastfd->next = thisfd->next;
+						if (lastfd)
+							lastfd->next = thisfd->next;
 						free_fd = thisfd;
 						safe_close(&(free_fd->fd));
 
@@ -1092,8 +1094,8 @@ static int read_from_local_sock(struct local_client *thisfd)
 					    pipe_client == newfd) {
 						thisfd->bits.localsock.
 						    pipe_client = NULL;
-
-						lastfd->next = newfd->next;
+						if (lastfd)
+							lastfd->next = newfd->next;
 						free_fd = newfd;
 						newfd->next = lastfd;
 						free(free_fd);
-- 
1.7.3.4


