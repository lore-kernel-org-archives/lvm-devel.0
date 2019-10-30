From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:44:41 -0400
Subject: master - lvmdbusd: Prevent running --nojson with VDO support
Message-ID: <201910301544.x9UFif7O016790@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=df2292020bd9298d511e4e2fb6a54fe0cb6e7607
Commit:        df2292020bd9298d511e4e2fb6a54fe0cb6e7607
Parent:        5b224d58f7cb72852c0bad87d3a0b4fb9250b132
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Oct 9 11:20:18 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbusd: Prevent running --nojson with VDO support

---
 daemons/lvmdbusd/main.py |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index de384ce..c128535 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -131,6 +131,10 @@ def main():
 	# exists.
 	cfg.vdo_support = supports_vdo()
 
+	if cfg.vdo_support and not cfg.args.use_json:
+		log_error("You cannot specify --nojson when lvm has VDO support")
+		sys.exit(1)
+
 	# List of threads that we start up
 	thread_list = []
 


