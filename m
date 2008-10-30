From: Petr Rockai <prockai@redhat.com>
Date: Thu, 30 Oct 2008 19:26:05 +0100
Subject: [PATCH] (10/11) conflict resolution with hotspare changes
Message-ID: <87ljw62b42.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this is just an explicit patch doing the conflict resolution, and is mostly for
reference. The vgreduce part has already appeared as part of the previous
patch, the metadata.c bit just clarifies what is the right resolution of the
unresolved conflict that appeared in one of the previous patches.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-lvmlib-hotspare-merge.diff
Type: text/x-diff
Size: 3820 bytes
Desc: lvmlib-hotspare-merge.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20081030/637d357c/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
