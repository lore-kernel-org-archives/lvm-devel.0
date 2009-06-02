From: Petr Rockai <prockai@redhat.com>
Date: Tue, 02 Jun 2009 20:51:15 +0200
Subject: [PATCH] lvconvert --repair prompts and policies
In-Reply-To: <873aaybhzz.fsf@mornfall.net> (Petr Rockai's message of "Thu, 21
	May 2009 17:20:00 +0200")
References: <873aaybhzz.fsf@mornfall.net>
Message-ID: <87d49mcvvg.fsf@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this is a new iteration of the patch, that hopefully addresses everyone's
concerns. For "normal" use (manual), it will prompt whether replacement of
devices is desired, with -y and -f to select yes and no respectively. Moreover,
--use-policies is provided that will read and use the lvm.conf mirror policy
settings.

We use --use-policies for dmeventd.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-repair-policies.diff
Type: text/x-diff
Size: 8138 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090602/d6471f13/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
