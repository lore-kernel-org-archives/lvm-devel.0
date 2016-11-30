From: tasleson <tasleson@fedoraproject.org>
Date: Wed, 30 Nov 2016 21:59:33 +0000 (UTC)
Subject: master - lvmdbusd: Remove unused variable
Message-ID: <20161130215933.CB6F46106B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b0757ac96e5c0f50e8d088200eb1ad62e535fcb6
Commit:        b0757ac96e5c0f50e8d088200eb1ad62e535fcb6
Parent:        0b8bf73a63d8dbd9fa32a32c7d47a277d4fb8eb1
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Nov 29 17:02:53 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Nov 30 15:59:06 2016 -0600

lvmdbusd: Remove unused variable

This variable has been un-used for a long time.
---
 daemons/lvmdbusd/cfg.py |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/cfg.py b/daemons/lvmdbusd/cfg.py
index 0612154..afb682c 100644
--- a/daemons/lvmdbusd/cfg.py
+++ b/daemons/lvmdbusd/cfg.py
@@ -38,7 +38,6 @@ SHELL_IN_USE = None
 # Lock used by pprint
 stdout_lock = multiprocessing.Lock()
 
-kick_q = multiprocessing.Queue()
 worker_q = queue.Queue()
 
 # Main event loop


