From: Petr Rockai <prockai@redhat.com>
Date: Tue, 08 Jul 2008 15:14:38 +0200
Subject: [PATCH] (1/5) partial volume group metadata handling
Message-ID: <87y74cikld.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this is the patch I have sent previously (on 5th May), with coding style and
naming cleanups (and one backward compatibility fix to flag reading), plus
rebased to current CVS. It provides the basic library support for improved
partial volume group handling. Patches for tools that build on the new
capabilities will follow soon.

The basic new features are:
- PVs are flagged with MISSING_PV appropriately
- LVs are flagged with PARTIAL_LV if they are incomplete (in any way)
- partial VGs will be read in by default and will have PARTIAL_VG status flag
  set (previously, they would be ignored by tools without activating special
  "partial mode", which is now deprecated)

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lib-partial-metadata.diff
Type: text/x-diff
Size: 13261 bytes
Desc: lib-partial-metadata.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080708/c03979f3/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
