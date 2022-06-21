From: cat@catcream.org <cat@catcream.org>
Date: Tue, 21 Jun 2022 21:21:26 +0200 (CEST)
Subject: Fix lvm2 for musl libc
Message-ID: <N56haDY--3-2@catcream.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi! These patches fix lvm2 for musl.

freopen is used in place of the assignment operator since the standard streams are const in musl. https://www.gnu.org/software/libc/manual/html_node/Standard-Streams.html (it says on this page that the standard streams may not be modifiable on other systems).

The mallinfo patch is just copied from Alpine Linux and it makes _allocate_memory not do anything if glibc isn't used. I don't know if that is fine, and if not I'd probably need some help properly making the function posix compliant, thanks. 

-- 
 Sent with Tutanota, enjoy secure & ad-free emails. 
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-2.03.14-freopen_n2.patch
Type: text/x-patch
Size: 575 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20220621/3594a4a7/attachment.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-2.03.14-r1-fopen-to-freopen.patch
Type: text/x-patch
Size: 1306 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20220621/3594a4a7/attachment-0001.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-2.03.14-r1-mallinfo.patch
Type: text/x-patch
Size: 665 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20220621/3594a4a7/attachment-0002.bin>
