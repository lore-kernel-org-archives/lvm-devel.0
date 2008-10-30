From: Petr Rockai <prockai@redhat.com>
Date: Thu, 30 Oct 2008 19:00:20 +0100
Subject: [PATCH] (4/11) start using vg_read_for_update
Message-ID: <87ljw63qvf.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this patch starts converting some tools to use the (at this time still fairly
rudimentary) vg_read_for_update. More API unification will follow in later
patches.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-lvmlib-use-vg_read_for_update.diff
Type: text/x-diff
Size: 10565 bytes
Desc: lvmlib-use-vg_read_for_update.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20081030/6270b007/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
