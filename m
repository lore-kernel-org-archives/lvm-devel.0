From: Petr Rockai <prockai@redhat.com>
Date: Mon, 02 Mar 2009 18:01:59 +0100
Subject: [PATCH] Small lvconvert refactor + BZ 463272 fix
Message-ID: <878wnnluyg.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

the two attached patches should address the issue with "--mirrorlog disk" being
lost on partial down-conversion of mirrors.

I suspect this will conflict horribly with lvconvert --repair, but I'll fix
that up later. The patch should be relatively transparent otherwise. The
refactor makes it much easier (and nicer and safer) to formulate the actual
fix.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-a.diff
Type: text/x-diff
Size: 3213 bytes
Desc: lvconvert-refactor.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090302/d1ced7f7/attachment.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-b.diff
Type: text/x-diff
Size: 1121 bytes
Desc: lvconvert-fix-bz463272.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090302/d1ced7f7/attachment-0001.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
