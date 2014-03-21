From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:32:09 +0000 (UTC)
Subject: master - cleanup: clvmd uses struct initializers
Message-ID: <20140321213209.4C07660F05@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0d449fe183936be5790e7c59d157fe6c8334a914
Commit:        0d449fe183936be5790e7c59d157fe6c8334a914
Parent:        9196274c1efb16731ec4ce53adb46366411b7c14
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 21 12:56:56 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:27 2014 +0100

cleanup: clvmd uses struct initializers

Code easier to read
---
 daemons/clvmd/clvmd.c |   59 ++++++++++++++++++++-----------------------------
 1 files changed, 24 insertions(+), 35 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 9e58fd0..ac570b6 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1541,26 +1541,21 @@ static void process_remote_command(struct clvm_header *msg, int msglen, int fd,
 			 ntohl(version_nums[1]), ntohl(version_nums[2]));
 
 		if (ntohl(version_nums[0]) != CLVMD_MAJOR_VERSION) {
-			struct clvm_header byebyemsg;
-			DEBUGLOG
-			    ("Telling node %s to go away because of incompatible version number\n",
-			     node);
-			log_notice
-			    ("Telling node %s to go away because of incompatible version number %d.%d.%d\n",
-			     node, ntohl(version_nums[0]),
-			     ntohl(version_nums[1]), ntohl(version_nums[2]));
-
-			byebyemsg.cmd = CLVMD_CMD_GOAWAY;
-			byebyemsg.status = 0;
-			byebyemsg.flags = 0;
-			byebyemsg.arglen = 0;
-			byebyemsg.clientid = 0;
-			clops->cluster_send_message(&byebyemsg, sizeof(byebyemsg),
-					     our_csid,
-					     "Error Sending GOAWAY message");
-		} else {
+			struct clvm_header byebyemsg = {
+				.cmd = CLVMD_CMD_GOAWAY
+			};
+
+			DEBUGLOG("Telling node %s to go away because of incompatible version number\n",
+				 node);
+			log_notice("Telling node %s to go away because of incompatible version number %d.%d.%d\n",
+				   node, ntohl(version_nums[0]),
+				   ntohl(version_nums[1]), ntohl(version_nums[2]));
+
+			clops->cluster_send_message(&byebyemsg, sizeof(byebyemsg), our_csid,
+						    "Error Sending GOAWAY message");
+		} else
 			clops->add_up_node(csid);
-		}
+
 		return;
 	}
 
@@ -1594,24 +1589,18 @@ static void process_remote_command(struct clvm_header *msg, int msglen, int fd,
 			agghead->clientid = msg->clientid;
 			agghead->arglen = replylen;
 			agghead->node[0] = '\0';
-			send_message(aggreply,
-				     sizeof(struct clvm_header) +
-				     replylen, csid, fd,
-				     "Error sending command reply");
+			send_message(aggreply, sizeof(struct clvm_header) + replylen,
+				     csid, fd, "Error sending command reply");
 		} else {
-			struct clvm_header head;
-
-			DEBUGLOG("Error attempting to realloc return buffer\n");
 			/* Return a failure response */
-			head.cmd = CLVMD_CMD_REPLY;
-			head.status = ENOMEM;
-			head.flags = 0;
-			head.clientid = msg->clientid;
-			head.arglen = 0;
-			head.node[0] = '\0';
-			send_message(&head, sizeof(struct clvm_header), csid,
-				     fd, "Error sending ENOMEM command reply");
-			return;
+			struct clvm_header reply = {
+				.cmd = CLVMD_CMD_REPLY,
+				.status = ENOMEM,
+				.clientid = msg->clientid
+			};
+			DEBUGLOG("Error attempting to realloc return buffer\n");
+			send_message(&reply, sizeof(reply), csid, fd,
+				     "Error sending ENOMEM command reply");
 		}
 	}
 


