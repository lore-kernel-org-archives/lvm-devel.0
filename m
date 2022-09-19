From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:14 +0000 (GMT)
Subject: main - lvmdbusd: Set LVM_COMMAND_PROFILE=lvmdbusd
Message-ID: <20220919155814.DECC2385842B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a5e6947d74f7b88f7f0df4328a923ad82a970634
Commit:        a5e6947d74f7b88f7f0df4328a923ad82a970634
Parent:        9693709b4642c7ef0c82f117b4f776a1e688d851
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 24 15:37:56 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Set LVM_COMMAND_PROFILE=lvmdbusd

We need this to prevent lvm from interleaving the JSON output with errors
written to stderr.
---
 daemons/lvmdbusd/main.py | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index dc6aa2277..c58c518d1 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -132,8 +132,10 @@ def main():
 	start = time.time()
 	use_session = os.getenv('LVMDBUSD_USE_SESSION', False)
 
-	# Ensure that we get consistent output for parsing stdout/stderr
+	# Ensure that we get consistent output for parsing stdout/stderr and that we
+	# are using the lvmdbusd profile.
 	os.environ["LC_ALL"] = "C"
+	os.environ["LVM_COMMAND_PROFILE"] = "lvmdbusd"
 
 	# Add simple command line handling
 	cfg.args = process_args()

