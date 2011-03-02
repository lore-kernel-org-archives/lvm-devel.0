From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  2 Mar 2011 19:09:07 +0100
Subject: [PATCH 1/2] Fix read byte from char[-1] position
In-Reply-To: <cover.1299089143.git.zkabelac@redhat.com>
References: <cover.1299089143.git.zkabelac@redhat.com>
Message-ID: <4e9cb7c98861937ffc9ce6ac53b3e58124a2eb6f.1299089143.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When the ->params is empty string - access is made on the byte
before allocated buffer (catched by valgrind) - in case it would
constains 0x20 - it would even overwrite this buffer.
So fix by checking len > 0 before doing such access.

Optimise the code and use len counter instead of multiple strlen calls.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/ioctl/libdm-iface.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 2f96a0f..b99f885 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1836,6 +1836,7 @@ static int _reload_with_suppression_v4(struct dm_task *dmt)
 {
 	struct dm_task *task;
 	struct target *t1, *t2;
+	size_t len;
 	int r;
 
 	/* New task to get existing table information */
@@ -1878,8 +1879,9 @@ static int _reload_with_suppression_v4(struct dm_task *dmt)
 	t2 = task->head;
 
 	while (t1 && t2) {
-		while (t2->params[strlen(t2->params) - 1] == ' ')
-			t2->params[strlen(t2->params) - 1] = '\0';
+		len = strlen(t2->params);
+		while (len-- > 0 && t2->params[len] == ' ')
+			t2->params[len] = '\0';
 		if ((t1->start != t2->start) ||
 		    (t1->length != t2->length) ||
 		    (strcmp(t1->type, t2->type)) ||
-- 
1.7.4.1


