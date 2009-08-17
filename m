From: Daniel Mierswa <impulze@impulze.org>
Date: Mon, 17 Aug 2009 21:58:07 +0200
Subject: [PATCH] replace siginterrupt with conforming sigaction
Message-ID: <4A89B64F.1020301@impulze.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


POSIX.1-2008 marks siginterrupt obsolete, use sigaction instead.
Implementation taken from online documents which already did the
transition.

Signed-off-by: Daniel Mierswa <impulze@impulze.org>
---
 lib/locking/file_locking.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)


-------------- next part --------------
A non-text attachment was scrubbed...
Name: 0001-replace-siginterrupt-with-conforming-sigaction.patch
Type: text/x-patch
Size: 538 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090817/16cd9f07/attachment.bin>
