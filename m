From: James Le Cuirot <chewi@aura-online.co.uk>
Date: Sat, 12 Nov 2011 13:49:43 +0000
Subject: [PATCH] Fix Gentoo support in lvm2create_initrd
Message-ID: <20111112134943.45692caf@symphony.aura-online.co.uk>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gentoo's MAKEDEV has moved (probably some time ago) from /usr/sbin
to /sbin. This fixes that and documents the option as well since I
didn't even know it existed until I looked at the source. Note that
this patch doesn't include the generated pod2man changes because my
version is much newer and it changes a lot of other lines too.
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2create_initrd-gentoo.patch
Type: text/x-patch
Size: 2186 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20111112/a59e68de/attachment.bin>
