From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 04 Jan 2008 10:13:19 -0500
Subject: [PATCH lvconvert 9/11] Add a new attr field char for the CONVERTING LV
In-Reply-To: <477E48D8.4050404@ce.jp.nec.com>
References: <477E48D8.4050404@ce.jp.nec.com>
Message-ID: <477E4D0F.6080204@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The patch changes the reporting format to show the conversion
structure.

# lvs -o+convert_lv vg
  LV    VG   Attr   LSize Origin Snap%  Move Log Copy%  Convert          
  lvol0 vg   cwi--- 1.00G                               lvol0_mimagetmp_2

'c' in the 'Attr' field means 'LV under conversion'.
'Convert' field points to the temporary LV for the conversion.

Might be better to add a new char for Attr field than
using volume-type char.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-add-attr-char-for-converting.patch
Type: text/x-patch
Size: 3974 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080104/ed53e075/attachment.bin>
