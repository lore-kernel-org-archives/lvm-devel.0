From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 20 Mar 2017 11:10:58 -0400
Subject: master - lvmdbusd: Update state during pv move
Message-ID: <201703201510.v2KFAwp5025702@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b65a9230a359de82cb4b5b2e802a493b72d46c4f
Commit:        b65a9230a359de82cb4b5b2e802a493b72d46c4f
Parent:        3ead4fb7ac3006a4c4377a88da22c22e6d426035
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Mar 15 14:19:55 2017 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Mar 20 10:08:39 2017 -0500

lvmdbusd: Update state during pv move

Periodically update the state during pv move so that all the different
dbus objects reflect something close to reality during the process.
---
 daemons/lvmdbusd/background.py |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmdbusd/background.py b/daemons/lvmdbusd/background.py
index e870c05..f7f77d5 100644
--- a/daemons/lvmdbusd/background.py
+++ b/daemons/lvmdbusd/background.py
@@ -64,6 +64,10 @@ def _move_merge(interface_name, command, job_state):
 				(device, ignore, percentage) = line_str.split(':')
 				job_state.Percent = round(
 					float(percentage.strip()[:-1]), 1)
+
+				# While the move is in progress we need to periodically update
+				# the state to reflect where everything is at.
+				cfg.load()
 		except ValueError:
 			log_error("Trying to parse percentage which failed for %s" %
 				line_str)


