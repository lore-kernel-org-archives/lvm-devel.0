From: Petr Rockai <prockai@redhat.com>
Date: Thu, 30 Oct 2008 18:50:20 +0100
Subject: [PATCH] (1/11) rename vg_read to vg_read_internal
Message-ID: <873aie55wj.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello lvm-devel,

this is a first patch in my "lvmlib" series. This work is not completely done,
but it does pass the testsuite. Please note, that the patches are chopped up in
a somewhat arbitrary manner, as it is fairly hard to come up with a good
ordering in the pretty long history of the patchset. Also please note that
parts of these patches, especially early in the series are obsoleted by later
ones, so it would make sense to at least glance over all of the patches first
and then go into more detailed review process.

This first preparatory patch just renames vg_read to vg_read_internal so it's
easily spotted and the "preferred" vg_read name is freed.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-rename-vg_read.diff
Type: text/x-diff
Size: 12520 bytes
Desc: lvmlib-rename-vg_read.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20081030/142ca976/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
