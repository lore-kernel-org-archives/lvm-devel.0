From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 20 Feb 2014 14:06:22 +0000 (UTC)
Subject: master - coverity: check dm_strncpy return value in dmeventd/_get_parameters
Message-ID: <20140220140622.268D160E34@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bbe4aca7c42ee3b1e620fb673a739b4b0f777144
Commit:        bbe4aca7c42ee3b1e620fb673a739b4b0f777144
Parent:        08116a4962bef2a36549c5496b3230862d3c93ca
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Feb 20 15:06:13 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Feb 20 15:06:13 2014 +0100

coverity: check dm_strncpy return value in dmeventd/_get_parameters

---
 daemons/dmeventd/dmeventd.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 1d979fa..4a17fb2 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -531,7 +531,8 @@ static int _get_parameters(struct message_data *message_data) {
 	msg->size = strlen(buf) + 1;
 	if (!(msg->data = dm_malloc(msg->size)))
 		goto_out;
-	dm_strncpy(msg->data, buf, msg->size);
+	if (!dm_strncpy(msg->data, buf, msg->size))
+		goto_out;
 	r = 0;
 out:
 	return r;


