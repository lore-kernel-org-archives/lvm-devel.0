From: Petr Rockai <prockai@redhat.com>
Date: Fri, 11 Jul 2008 15:42:30 +0200
Subject: [PATCH] (2/3) tools & missing PV handling
Message-ID: <87y7481qrd.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this is a naming cleanup of the former tools & partial volume group handling
patch. The handles_partial flag has been renamed to handles_missing_pvs to
separate terminology and clear up the naming mess somewhat.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: tools-handles_missing_pvs.diff
Type: text/x-diff
Size: 3431 bytes
Desc: tools-handles_missing_pvs.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080711/c25a5b8c/attachment.bin>
-------------- next part --------------

Yours,
    Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
