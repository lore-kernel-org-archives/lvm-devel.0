From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 23 Apr 2023 11:09:35 +0000 (GMT)
Subject: main - lvmdbus: preserve PATH envvar
Message-ID: <20230423110935.EA1CD3858C74@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=afc02ae6e7234e1190cedf5c74ca3d6367efd7d1
Commit:        afc02ae6e7234e1190cedf5c74ca3d6367efd7d1
Parent:        ce8835d4c429bd87da5731e3015d9ddc9e3fb888
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 23 12:49:37 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 23 12:49:37 2023 +0200

lvmdbus: preserve PATH envvar

---
 daemons/lvmdbusd/lvm_shell_proxy.py.in | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py.in b/daemons/lvmdbusd/lvm_shell_proxy.py.in
index b8c8fa565..02a776e1d 100755
--- a/daemons/lvmdbusd/lvm_shell_proxy.py.in
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py.in
@@ -154,6 +154,8 @@ class LVMShellProxy(object):
 
 		# If any env variables contain LVM we will propagate them too
 		for k, v in os.environ.items():
+			if "PATH" in k:
+				local_env[k] = v
 			if "LVM" in k:
 				local_env[k] = v
 

