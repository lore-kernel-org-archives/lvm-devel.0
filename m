From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:57:18 +0200
Subject: [PATCH 06/25] Replicator: man page update for lvm
In-Reply-To: <cover.1281256234.git.zkabelac@redhat.com>
References: <cover.1281256234.git.zkabelac@redhat.com>
Message-ID: <6689adff8919ad9e925245df3b927fd099f6408d.1281256235.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add new reserved names to lvm man page.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 man/lvm.8.in |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/man/lvm.8.in b/man/lvm.8.in
index e38ce4f..7d070f7 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -271,7 +271,8 @@ The following characters are valid for VG and LV names:
 VG and LV names cannot begin with a hyphen.
 There are also various reserved names that are used internally by lvm that can not be used as LV or VG names.
 A VG cannot be called anything that exists in /dev/ at the time of creation, nor can it be called '.' or '..'.
-A LV cannot be called '.' '..' 'snapshot' or 'pvmove'. The LV name may also not contain the strings '_mlog' or '_mimage'
+A LV cannot be called '.' '..' 'snapshot' or 'pvmove'. The LV name may also not contain the strings 
+'_mlog', '_mimage', '_rlog', '_slog', '_rimage'.
 
 
 .SH DIAGNOSTICS
-- 
1.7.2.1


