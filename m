From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 24 Mar 2016 11:43:50 +0000 (UTC)
Subject: master - monitoring: sync /dev content before contacting dmeventd for monitor/unmonitor
Message-ID: <20160324114350.CA802610F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6129d2e64d14047169048775dc7081135c0fcc50
Commit:        6129d2e64d14047169048775dc7081135c0fcc50
Parent:        82d92009ae37bea3cd6a3f754c25d56b12959676
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Mar 24 11:13:21 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 24 12:40:19 2016 +0100

monitoring: sync /dev content before contacting dmeventd for monitor/unmonitor

dmeventd daemon may call further code itself that looks at /dev, e.g.
via dmeventd_lvm2_command call. We need to have a consistent view of
the /dev content at that time. Therefore, sync /dev content before
calling monitoring hook which contacts dmeventd.

This problem was quite hidden before, but now it has manifested itself
because of recent additions to dev-cache code where we started looking
at device holders as seen in sysfs. What happened here was that the
device was already in sysfs, but not yet under /dev and this triggered
the new error message sometimes:

  log_error("%s: failed to find associated device structure for holder %s.", devname, devpath);

This problem has manifested recently in our api/pytest.sh test from
testsuite where we create thin pool LVs and thin LVs and hence it also
causes dmeventd to be used as well and these error messages were
visible there.
---
 lib/activate/activate.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 2eb24d4..7dce0da 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1746,6 +1746,12 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 		if (test_mode())
 			continue;
 
+		/*
+		 * Sync all queued device names/symlinks so dmeventd
+		 * has consistent view during possible device scan.
+		 */
+		fs_unlock();
+
 		/* FIXME specify events */
 		if (!monitor_fn(seg, 0)) {
 			log_error("%s: %s segment monitoring function failed.",


