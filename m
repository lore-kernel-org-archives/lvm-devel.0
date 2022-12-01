From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu,  1 Dec 2022 07:21:35 +0000 (GMT)
Subject: rhel-8.8.0 - lvmdbusd: Set LVM_COMMAND_PROFILE=lvmdbusd
Message-ID: <20221201072135.6D1813858C54@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0aa45120e92fe8b0f379d00f3a031e3c53feca43
Commit:        0aa45120e92fe8b0f379d00f3a031e3c53feca43
Parent:        73943825501daede9963bb5d15abbc4d36febb40
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 24 15:37:56 2022 -0500
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Nov 28 17:11:21 2022 +0100

lvmdbusd: Set LVM_COMMAND_PROFILE=lvmdbusd

We need this to prevent lvm from interleaving the JSON output with errors
written to stderr.

(cherry picked from commit a5e6947d74f7b88f7f0df4328a923ad82a970634)
---
 daemons/lvmdbusd/main.py | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index b0a82d492..eaea13ef8 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -112,8 +112,10 @@ def main():
 
 	use_session = os.getenv('LVMDBUSD_USE_SESSION', False)
 
-	# Ensure that we get consistent output for parsing stdout/stderr
+	# Ensure that we get consistent output for parsing stdout/stderr and that we
+	# are using the lvmdbusd profile.
 	os.environ["LC_ALL"] = "C"
+	os.environ["LVM_COMMAND_PROFILE"] = "lvmdbusd"
 
 	cfg.args = parser.parse_args()
 	cfg.create_request_entry = RequestEntry

