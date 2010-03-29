From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 29 Mar 2010 17:27:23 +0200
Subject: [PATCH 5/7] Force C locale
In-Reply-To: <cover.1269876115.git.zkabelac@redhat.com>
References: <cover.1269876115.git.zkabelac@redhat.com>
Message-ID: <03ae6ffc85481c0cc1f995d5102fe365da2c5f91.1269876115.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As we need to use mlockall() enforce "C" locales for dmeventd.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/dmeventd/dmeventd.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index f4b664b..0958e21 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1698,6 +1698,9 @@ int main(int argc, char *argv[])
 		}
 	}
 
+	/* Force C locale */
+	setenv("LANG", "C", 1);
+
 	if (!_debug)
 		_daemonize();
 
-- 
1.7.0.1


