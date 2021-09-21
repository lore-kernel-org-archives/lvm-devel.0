From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 21 Sep 2021 19:50:59 +0000 (GMT)
Subject: main - clang: check for buffer existance
Message-ID: <20210921195059.69ECA3858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=462ac47003e14975b91832f19bc287bd1a775bb4
Commit:        462ac47003e14975b91832f19bc287bd1a775bb4
Parent:        bb6fd1a15f32d79ddaa351704dea47ad9e5ab9be
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 21 18:07:41 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 21 21:03:47 2021 +0200

clang: check for buffer existance

Make obvious to analyzer we can't get NULL here.
---
 daemons/dmeventd/dmeventd.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 75672a7fd..46b3ff12f 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -678,6 +678,9 @@ static int _get_status(struct message_data *message_data)
 	char **buffers;
 	char *message;
 
+	if (!message_data->id)
+		return -EINVAL;
+
 	_lock_mutex();
 	count = dm_list_size(&_thread_registry);
 	buffers = alloca(sizeof(char*) * count);


