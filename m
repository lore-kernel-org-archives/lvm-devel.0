From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:43:03 +0000 (UTC)
Subject: master - activation: report error message
Message-ID: <20120823124303.C8EF8A0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5d0e7fb4edbe2c4e999eaa6210b6c9e25bdd5e91
Commit:        5d0e7fb4edbe2c4e999eaa6210b6c9e25bdd5e91
Parent:        57c0f72b1d0349382c226c2b5614489b59db99e8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 29 10:18:28 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:38:48 2012 +0200

activation: report error message

If the monitoring activation failed and we have not yet
reported error - give the user error message for failure reason.
---
 lib/activate/activate.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 512adcf..185ba5f 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1391,6 +1391,9 @@ int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
 			r = (monitored && monitor) || (!monitored && !monitor);
 	}
 
+	if (!r && !error_message_produced())
+		log_error("%sonitoring %s/%s failed.", monitor ? "M" : "Not m",
+			  lv->vg->name, lv->name);
 	return r;
 #else
 	return 1;


