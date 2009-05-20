From: Petr Rockai <prockai@redhat.com>
Date: Wed, 20 May 2009 22:30:06 +0200
Subject: [PATCH] (rebase, v2) Fix BZ 463272.
Message-ID: <87ab57qzzl.fsf@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this didn't get any review/acks last time I posted it. Moreover, it has gotten
out of date due to lvconvert --repair getting through. I am therefore attaching
a new version of the two patches that apply (and work) on top of current CVS.

I also believe that this patch fixes some corner cases in lvconvert --repair
(eg.  when a double failure in a 3-way mirror with disk log takes out one of
the legs and the log).

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-refactor.diff
Type: text/x-diff
Size: 3242 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090520/7b82f776/attachment.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-bz463272.diff
Type: text/x-diff
Size: 1228 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090520/7b82f776/attachment-0001.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
