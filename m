From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  7 Jul 2010 14:29:36 +0200
Subject: [PATCH 6/6] Exit status 0 for 'dmsetup -c -o help'
In-Reply-To: <cover.1278505444.git.zkabelac@redhat.com>
References: <cover.1278505444.git.zkabelac@redhat.com>
Message-ID: <021570bdb0ff125d08c6b92a411fc34a02ef48c2.1278505444.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/dmsetup.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 5e71542..479cbb0 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3340,6 +3340,7 @@ int main(int argc, char **argv)
 	}
 
 	if (argc == 0) {
+		r = 0;
 		_usage(stderr);
 		goto out;
 	}
-- 
1.7.1.1


