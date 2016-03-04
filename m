From: tasleson <tasleson@fedoraproject.org>
Date: Fri,  4 Mar 2016 16:24:55 +0000 (UTC)
Subject: master - lvmdbusd: Set locale
Message-ID: <20160304162455.0179260D59@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6c781751261a6e75f8e3e63f5efbecf467d63476
Commit:        6c781751261a6e75f8e3e63f5efbecf467d63476
Parent:        f94fe2c91fc995e2d57f7689f01d8d15d72858cc
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Mar 4 10:13:04 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Mar 4 10:13:04 2016 -0600

lvmdbusd: Set locale

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 daemons/lvmdbusd/main.py |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 6cabcc4..92006d0 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -103,6 +103,9 @@ def main():
 
 	use_session = os.getenv('LVMDBUSD_USE_SESSION', False)
 
+	# Ensure that we get consistent output for parsing stdout/stderr
+	os.environ["LC_ALL"] = "C"
+
 	args = parser.parse_args()
 
 	cfg.DEBUG = args.debug


