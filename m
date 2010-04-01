From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu,  1 Apr 2010 17:57:32 -0400
Subject: [PATCH 6/6] RFC: Change lvm2app version number from 1 to 2.
In-Reply-To: <1270159052-1181-6-git-send-email-dwysocha@redhat.com>
References: <1270159052-1181-1-git-send-email-dwysocha@redhat.com>
	<1270159052-1181-2-git-send-email-dwysocha@redhat.com>
	<1270159052-1181-3-git-send-email-dwysocha@redhat.com>
	<1270159052-1181-4-git-send-email-dwysocha@redhat.com>
	<1270159052-1181-5-git-send-email-dwysocha@redhat.com>
	<1270159052-1181-6-git-send-email-dwysocha@redhat.com>
Message-ID: <1270159052-1181-7-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This version number change reflects the memory handling change
for string-based pv/vg/lv string based attributes.
In addition, when adding support for tags, I forgot to increase
the version number.  Also, it might be nice to have a short list
of what has changed in the API since the last version, apart from
the WHATS_NEW lvm file.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 VERSION |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/VERSION b/VERSION
index d96250e..204b86d 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.63(1)-cvs (2010-03-09)
+2.02.63(2)-cvs (2010-03-09)
-- 
1.6.0.6


