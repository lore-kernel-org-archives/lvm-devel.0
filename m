From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:55:33 +0000 (UTC)
Subject: master - cleanup: dmeventd simplify status processing
Message-ID: <20140418145533.8F4F160E56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=13d05211d006a63035afea44fa8a4b1222130cd5
Commit:        13d05211d006a63035afea44fa8a4b1222130cd5
Parent:        4fb588c34ee9b64333ad39ab039d657cf6e958ab
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 18 13:34:44 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:38:52 2014 +0200

cleanup: dmeventd simplify status processing

Since we always know the string length, use simplier memcpy.
---
 daemons/dmeventd/dmeventd.c |   25 ++++++++++++-------------
 1 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index a907ca6..81da166 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -473,25 +473,24 @@ static int _get_status(struct message_data *message_data)
 			_unlock_mutex();
 			goto out;
 		}
-		++ i;
-		size += current;
+		++i;
+		size += current; /* count with trailing '\0' */
 	}
 	_unlock_mutex();
 
-	msg->size = size + strlen(message_data->id) + 1;
-	msg->data = dm_malloc(msg->size);
-	if (!msg->data)
+	len = strlen(message_data->id);
+	msg->size = size + len + 1;
+	dm_free(msg->data);
+	if (!(msg->data = dm_malloc(msg->size)))
 		goto out;
-	*msg->data = 0;
 
-	message = msg->data;
-	strcpy(message, message_data->id);
-	message += strlen(message_data->id);
-	*message = ' ';
-	message ++;
+	memcpy(msg->data, message_data->id, len);
+	message = msg->data + len;
+	*message++ = ' ';
 	for (j = 0; j < i; ++j) {
-		strcpy(message, buffers[j]);
-		message += strlen(buffers[j]);
+		len = strlen(buffers[j]);
+		memcpy(message, buffers[j], len);
+		message += len;
 	}
 
 	ret = 0;


