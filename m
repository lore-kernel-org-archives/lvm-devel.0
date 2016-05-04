From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  4 May 2016 17:12:18 +0000 (UTC)
Subject: master - pvcreate: improve debug message
Message-ID: <20160504171218.65E1960E9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7c1e6011644abd00dac7f71baf330f69bd076381
Commit:        7c1e6011644abd00dac7f71baf330f69bd076381
Parent:        1df6769acabd99fe062ebac1c8290da1ef1020f7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 4 12:11:13 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 4 12:11:13 2016 -0500

pvcreate: improve debug message

state what the printed UUID is.
---
 tools/toollib.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index c86900a..f1fe5b1 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3818,8 +3818,8 @@ static int _pvcreate_check_single(struct cmd_context *cmd,
 	if (!found)
 		return 1;
 
-	log_debug("Checking device %s for pvcreate %.32s.",
-		  pv_dev_name(pv), pv->dev->pvid[0] ? pv->dev->pvid : "");
+	log_debug("Checking pvcreate arg %s which has existing PVID: %.32s.",
+		  pv_dev_name(pv), pv->dev->pvid[0] ? pv->dev->pvid : "<none>");
 
 	/*
 	 * This test will fail if the device belongs to an MD array.


