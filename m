From: Tony Asleson <tasleson@sourceware.org>
Date: Mon,  6 Mar 2023 17:26:17 +0000 (GMT)
Subject: main - lvmdbusd: Add needed env. variables
Message-ID: <20230306172617.3E85F3858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c8f2125b85afe043af1b2e887a80f882b8d8d7c7
Commit:        c8f2125b85afe043af1b2e887a80f882b8d8d7c7
Parent:        df6120e9f715c58327451f650c003d09842f33c7
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Mar 6 10:26:44 2023 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Mar 6 10:26:44 2023 -0600

lvmdbusd: Add needed env. variables

When running lvmdb.py by itself for testing we need these.
---
 daemons/lvmdbusd/lvmdb.py.in | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/daemons/lvmdbusd/lvmdb.py.in b/daemons/lvmdbusd/lvmdb.py.in
index 41fedb80f..e6bec926a 100644
--- a/daemons/lvmdbusd/lvmdb.py.in
+++ b/daemons/lvmdbusd/lvmdb.py.in
@@ -437,6 +437,8 @@ class DataStore(object):
 
 
 if __name__ == "__main__":
+	os.environ["LC_ALL"] = "C"
+	os.environ["LVM_COMMAND_PROFILE"] = "lvmdbusd"
 	pp = prettyprint.PrettyPrinter(indent=4)
 
 	ds = DataStore()

