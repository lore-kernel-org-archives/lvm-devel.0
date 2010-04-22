From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 22 Apr 2010 15:29:01 +0200
Subject: [PATCH 0/3] Regexp speedup
Message-ID: <cover.1271942633.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch set uses latest EJT code.
2 first patches reverts current regexp optimization code away.
3rd patch adds improved way of calculating dfa states 

Patch is not so well tested - but some elementar cases seems to be passing.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>

Zdenek Kabelac (3):
  Revert "Still not satisfactory..."
  Revert "Add a regex optimisation pass for shared character prefixes."
  New regexp code made by EJT.

 WHATS_NEW_DM           |    1 -
 libdm/regex/matcher.c  |  265 +++++++++++++++++++++++++++---------------------
 libdm/regex/parse_rx.c |  215 ++-------------------------------------
 libdm/regex/parse_rx.h |    1 +
 4 files changed, 159 insertions(+), 323 deletions(-)


