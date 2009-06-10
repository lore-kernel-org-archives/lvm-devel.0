From: Petr Rockai <prockai@redhat.com>
Date: Wed, 10 Jun 2009 19:28:04 +0200
Subject: [PATCH] Re-instate partial activation support in clustered mode.
Message-ID: <874ouom21n.fsf@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

the patch from September 2008 (partial activation revamp) broke clustered
activation for the partial mode. This is currently more serious, since
lvconvert --repair relies on this functionality (see BZ 504699).

-------------- next part --------------
A non-text attachment was scrubbed...
Name: cluster-partial.diff
Type: text/x-diff
Size: 2860 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090610/8919d281/attachment.bin>
-------------- next part --------------

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
