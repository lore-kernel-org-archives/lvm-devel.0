From: Petr Rockai <prockai@redhat.com>
Date: Thu, 30 Oct 2008 19:15:26 +0100
Subject: [PATCH] (7/11) API improvements
Message-ID: <873aie3q69.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this patch improves the API somewhat, by restructuring the way errors are
checked for by the client code: a vg_read_error function is provided for that,
and the vg_read(_for_update) has seen some improvements unrelated to that. It
also makes vg_read_for_update a simple front-end to vg_read, as vg_read will be
needed later to have the same capabilities, easily (this is done through the
READ_FOR_UPDATE flag). I admit that this is a little incoherent together in a
single patch, but that's how things winded up.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-lvmlib-newapi.diff
Type: text/x-diff
Size: 20708 bytes
Desc: lvmlib-new-api.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20081030/ea88f20a/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
