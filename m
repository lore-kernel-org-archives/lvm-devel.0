From: tasleson <tasleson@fedoraproject.org>
Date: Wed,  2 Nov 2016 21:48:04 +0000 (UTC)
Subject: master - lvmdbusd: main.py: change debug msg text
Message-ID: <20161102214804.4B1E260B20@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=95abadd13c468b56612c1966d28daddfdeee6e2e
Commit:        95abadd13c468b56612c1966d28daddfdeee6e2e
Parent:        60de09b00caf034367278adea420b67700c01b71
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Nov 1 17:52:51 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Nov 2 16:39:13 2016 -0500

lvmdbusd: main.py: change debug msg text

---
 daemons/lvmdbusd/main.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 93e035f..5fe1018 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -85,7 +85,7 @@ def process_request():
 					log_debug(
 						"Inspect method %s for too many refreshes" %
 						(str(req.method)))
-			log_debug("Complete ")
+			log_debug("Method complete ")
 		except queue.Empty:
 			pass
 		except Exception:


