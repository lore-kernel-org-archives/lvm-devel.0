From: Petr Rockai <prockai@redhat.com>
Date: Thu, 30 Oct 2008 19:04:47 +0100
Subject: [PATCH] (5/11) vg_read error returns, part 1
Message-ID: <87fxme3qo0.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this patch is the first attempt at allowing vg_read* users to infer more
information about the error, apart from "an error has happened and been
reported to the user". This will be useful whenever the tools need to
differentiate behaviour depending on the kind of error that has happened, as is
the case in a few spots -- those can be found in the later patches, when this
functionality is used. In this particular patch, it is used for
FAILED_NOTFOUND.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-lvmlib-vg_read-errors.diff
Type: text/x-diff
Size: 14734 bytes
Desc: lvmlib-vg_read-errors.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20081030/c82583f5/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
