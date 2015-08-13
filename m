From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 13 Aug 2015 23:10:00 +0000 (UTC)
Subject: master - dmsetup: Fix dmsetup return code.
Message-ID: <20150813231000.89D5860317@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6a93206882cb628a88dbd372d36dc8fc8cc5053a
Commit:        6a93206882cb628a88dbd372d36dc8fc8cc5053a
Parent:        043fb32c4b67d1456a77ab7caf0d077f419fae88
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Aug 14 00:09:40 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Aug 14 00:09:40 2015 +0100

dmsetup: Fix dmsetup return code.

---
 tools/dmsetup.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index b3820fe..c5be193 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -5832,7 +5832,7 @@ static int _do_report_wait(void)
 
 int main(int argc, char **argv)
 {
-	int r = 1;
+	int ret = 1, r;
 	const char *dev_dir;
 	const struct command *cmd;
 	const char *subcommand = NULL;
@@ -5975,9 +5975,12 @@ doit:
 		}
 
 		if (!r)
-			break;
+			goto_out;
 	} while (--_count);
 
+	/* Success */
+	ret = 0;
+
 out:
 	if (_report)
 		dm_report_free(_report);
@@ -5990,5 +5993,5 @@ out:
 	if (_initial_timestamp)
 		dm_timestamp_destroy(_initial_timestamp);
 
-	return r;
+	return ret;
 }


