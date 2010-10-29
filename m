From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 29 Oct 2010 21:54:16 +0200
Subject: Patch for fsadm bz 64146
Message-ID: <4CCB2668.8020809@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch address problem from  BZ 64146.

Instead of leaving lvresize to fail when running on the mounted fs (user
expects online resize to happen and it's currently possible only with -n
option) - this patch changes 'fsadm check' behavior so it returns success for
mounted  filesystem. This allows lvresize to processed further and run the
online resize even without passing -n option.

Anyone sees this modified behavior of fsadm script as a problem ?
(change success for mounted fs).

Zdenek
-------------- next part --------------
A non-text attachment was scrubbed...
Name: fsadm.patch
Type: text/x-patch
Size: 1315 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20101029/5612a977/attachment.bin>
