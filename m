From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Jun 2016 22:46:04 +0000 (UTC)
Subject: master - cleanup: add extra test for argc==0
Message-ID: <20160630224604.F12156109B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1e3411aa3724ee9ee32f5cb4378526b9c355854d
Commit:        1e3411aa3724ee9ee32f5cb4378526b9c355854d
Parent:        458918b31953943a3cc44976388f008ca850c124
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 30 10:27:10 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 1 00:44:48 2016 +0200

cleanup: add extra test for argc==0

Cleaup some compiler warning about posibility to allocate 0 size.
---
 daemons/cmirrord/functions.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/daemons/cmirrord/functions.c b/daemons/cmirrord/functions.c
index e9d3c09..757d8e8 100644
--- a/daemons/cmirrord/functions.c
+++ b/daemons/cmirrord/functions.c
@@ -573,6 +573,12 @@ static int clog_ctr(struct dm_ulog_request *rq)
 	for (argc = 0, p = rq->data; (p = strstr(p, " ")); p++, argc++)
 		*p = '\0';
 
+	if (!argc) {
+		LOG_ERROR("Received constructor request with bad data %s",
+			  rq->data);
+		return -EINVAL;
+	}
+
 	argv = malloc(argc * sizeof(char *));
 	if (!argv)
 		return -ENOMEM;


