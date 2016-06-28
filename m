From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 28 Jun 2016 19:24:41 +0000 (UTC)
Subject: master - lvmdbusd: Add --nojson command line option
Message-ID: <20160628192441.D991D6030D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1d3532d0a7d458550b53218a6b21798eab30b68e
Commit:        1d3532d0a7d458550b53218a6b21798eab30b68e
Parent:        e6e5c3d3ecb7de18ec2d103df8e5b0229df9ce1c
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Jun 28 13:32:39 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jun 28 13:32:39 2016 -0500

lvmdbusd: Add --nojson command line option

Add ability to not use the JSON output even if available.
---
 daemons/lvmdbusd/main.py |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index aa16a2e..f28b402 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -101,6 +101,10 @@ def main():
 						help="Dump debug messages", default=False,
 						dest='debug')
 
+	parser.add_argument("--nojson", action='store_false',
+						help="Do not use LVM JSON output", default=None,
+						dest='use_json')
+
 	use_session = os.getenv('LVMDBUSD_USE_SESSION', False)
 
 	# Ensure that we get consistent output for parsing stdout/stderr
@@ -137,7 +141,7 @@ def main():
 
 	cfg.load = load
 
-	cfg.db = lvmdb.DataStore()
+	cfg.db = lvmdb.DataStore(args.use_json)
 
 	# Start up thread to monitor pv moves
 	thread_list.append(


