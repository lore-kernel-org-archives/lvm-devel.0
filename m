From: Vojtech Trefny <vtrefny@redhat.com>
Date: Wed,  1 Jul 2020 13:27:47 +0200
Subject: [PATCH 2/2] lvmdbusd: Bump LVM DBus API version
In-Reply-To: <20200701112747.61278-1-vtrefny@redhat.com>
References: <20200701112747.61278-1-vtrefny@redhat.com>
Message-ID: <20200701112747.61278-2-vtrefny@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

So users can check for writecache support.
---
 daemons/lvmdbusd/manager.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index 2857e9a10..573a3966f 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -27,7 +27,7 @@ class Manager(AutomatedProperties):
 
 	@property
 	def Version(self):
-		return dbus.String('1.0.0')
+		return dbus.String('1.1.0')
 
 	@staticmethod
 	def handle_execute(rc, out, err):
-- 
2.25.4


