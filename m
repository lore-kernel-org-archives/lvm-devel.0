From: Petr Rockai <prockai@redhat.com>
Date: Tue, 08 Jul 2008 15:18:54 +0200
Subject: [PATCH] (2/5) tools & partial volume group handling
Message-ID: <87wsjwike9.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

the following two patches establish basic tool support for partial volume
groups, as defined by the previous patch for the library. The first one adds
handles_partial flag to toolcontext and enables the library to write out
partial volume group metadata, when this flag is set (it is off by default).

It also makes lvremove work on partial volume groups by default and adds
--partial flag to vgcfgrestore to allow it restoring partial volume groups.

The latter patch fixes vgreduce --removemissing to work with new partial VG
semantics.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: tools-handles_partial.diff
Type: text/x-diff
Size: 4633 bytes
Desc: tools-handles_partial.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080708/217f2f15/attachment.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: vgreduce-removemissing.diff
Type: text/x-diff
Size: 1053 bytes
Desc: vgreduce-removemissing.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080708/217f2f15/attachment-0001.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
