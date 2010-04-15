From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 15 Apr 2010 11:40:04 +0200
Subject: [PATCH 2/3] Script to create proper relative path
In-Reply-To: <cover.1271324076.git.zkabelac@redhat.com>
References: <cover.1271324076.git.zkabelac@redhat.com>
Message-ID: <f2442bfb7c86b162567d635487525116366244b8.1271324076.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This script takes two real paths and calculates relative
path between them. Script is used for creation of relative
path /usr/lib/lib.so -> /lib/lib.so.1.2

i.e.   relpath.sh   a/b/c/d  a/b/e/f/g/g  -> ../../e/f/g/g/

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 scripts/relpath.sh |   49 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 49 insertions(+), 0 deletions(-)
 create mode 100755 scripts/relpath.sh

diff --git a/scripts/relpath.sh b/scripts/relpath.sh
new file mode 100755
index 0000000..3e79a0d
--- /dev/null
+++ b/scripts/relpath.sh
@@ -0,0 +1,49 @@
+#!/bin/bash
+
+# usage: relpath from to
+#
+# modified script from to avoid print of ./:
+# http://stackoverflow.com/questions/2564634/bash-convert-absolute-path-into-relative-path-given-a-current-directory 
+# 
+
+from=${1%%/}
+to=${2%%/}
+
+test "$from" == "$to" && exit
+
+IFS="/"
+
+current=($from)
+absolute=($to)
+
+abssize=${#absolute[@]}
+cursize=${#current[@]}
+
+while [[ ${absolute[$level]} == ${current[$level]} ]]
+do
+    (( level++ ))
+    if (( level > abssize || level > cursize ))
+    then
+        break
+    fi
+done
+
+for ((i = level; i < cursize; i++))
+do
+    if ((i > level))
+    then
+        newpath=$newpath"/"
+    fi
+    newpath=$newpath".."
+done
+
+for ((i = level; i < abssize; i++))
+do
+    if [[ -n $newpath ]]
+    then
+        newpath=$newpath"/"
+    fi
+    newpath=$newpath${absolute[i]}
+done
+
+echo "$newpath/"
-- 
1.7.0.1


