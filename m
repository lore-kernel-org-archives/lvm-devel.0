From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 30 Jun 2022 16:00:40 +0000 (GMT)
Subject: main - lvmdbusd: Add debug output for which lvm binary is used
Message-ID: <20220630160040.590C73842AFC@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=51d9b686c08d963c61898d407d15abf39f129d72
Commit:        51d9b686c08d963c61898d407d15abf39f129d72
Parent:        b3407b16c1c7b5bff01e3bde4e0f62a2608682f8
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed May 25 15:59:11 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Jun 30 10:55:16 2022 -0500

lvmdbusd: Add debug output for which lvm binary is used

---
 daemons/lvmdbusd/main.py | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index b0a82d492..1e717ef69 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -127,6 +127,8 @@ def main():
 		log_error("You cannot specify --lvmshell and --nojson")
 		sys.exit(1)
 
+	log_debug("Using lvm binary: %s" % cfg.LVM_CMD)
+
 	# We will dynamically add interfaces which support vdo if it
 	# exists.
 	cfg.vdo_support = supports_vdo()

