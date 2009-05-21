From: Petr Rockai <prockai@redhat.com>
Date: Thu, 21 May 2009 17:20:00 +0200
Subject: [PATCH] [draft] add lvconvert --repair --auto that honours lvm.conf mirror policy
Message-ID: <873aaybhzz.fsf@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I'm attaching a draft version of basic configuration capability for automatic
mirror repairs. This will make dmeventd respect the two lvm.conf options
setting failed mirror replacement policies. It doesn't affect the basic
(manual) lvconvert --repair mode (I have added --auto for that purpose; it
might need a better name though).

Please note that the patch is untested yet, but I'd like to get feedback
anyway. Thanks!

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-repair-auto.diff
Type: text/x-diff
Size: 4768 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090521/8df90306/attachment.bin>
-------------- next part --------------

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
