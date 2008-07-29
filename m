From: Petr Rockai <prockai@redhat.com>
Date: Tue, 29 Jul 2008 15:25:34 +0200
Subject: [PATCH] (1/6) Partial metadata handling (one more take)
Message-ID: <87ljzk3jqp.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Here comes the newest-and-greatest rebase of the partial metadata patchset. I
believe all outstanding issues have been fixed by now in this foundation
patch. I have integrated all fixes that have turned out as part of other work
(partial activation, vgreduce, lvconvert work). Bar any unexpected issues, this
should be ready for merging.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lib-partial_metadata.diff
Type: text/x-diff
Size: 79 bytes
Desc: lib-partial_metadata.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080729/ab225a91/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
