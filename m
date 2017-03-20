From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 20 Mar 2017 11:10:52 -0400
Subject: master - lvmdbusd: Call add_no_notify for *move commands
Message-ID: <201703201510.v2KFAqY7025691@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7eeb093fdd314063eff7f14b8b6338523e0dd840
Commit:        7eeb093fdd314063eff7f14b8b6338523e0dd840
Parent:        2dc71fc291b3ac861298b4dd7b25963dd9325a4d
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Mar 15 10:58:41 2017 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Mar 20 10:08:38 2017 -0500

lvmdbusd: Call add_no_notify for *move commands

Missed this in change when "add_no_notify" was added.  This was causing
extra external events to process when we did moves.
---
 daemons/lvmdbusd/background.py |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/background.py b/daemons/lvmdbusd/background.py
index 19a2e6c..e870c05 100644
--- a/daemons/lvmdbusd/background.py
+++ b/daemons/lvmdbusd/background.py
@@ -11,7 +11,8 @@ import subprocess
 from . import cfg
 from .cmdhandler import options_to_cli_args
 import dbus
-from .utils import pv_range_append, pv_dest_ranges, log_error, log_debug
+from .utils import pv_range_append, pv_dest_ranges, log_error, log_debug,\
+	add_no_notify
 import os
 import threading
 
@@ -42,6 +43,10 @@ def _move_merge(interface_name, command, job_state):
 	# the command always as we will be getting periodic output from them on
 	# the status of the long running operation.
 	command.insert(0, cfg.LVM_CMD)
+
+	# Instruct lvm to not register an event with us
+	command = add_no_notify(command)
+
 	process = subprocess.Popen(command, stdout=subprocess.PIPE,
 								env=os.environ,
 								stderr=subprocess.PIPE, close_fds=True)


