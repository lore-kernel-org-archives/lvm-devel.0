From: Petr Rockai <prockai@redhat.com>
Date: Sun, 10 May 2009 21:24:52 +0200
Subject: [PATCH 2/7] Never set mirror log and images directly visible in metadata.
In-Reply-To: <4A07202D.1010903@redhat.com> (Milan Broz's message of "Sun, 10
	May 2009 20:42:53 +0200")
References: <cover.1241620083.git.mbroz@redhat.com>
	<cover.1241620083.git.mbroz@redhat.com>
	<a3d0392fa15ad5ecbc874cb5419a0177011655ed.1241620083.git.mbroz@redhat.com>
	<87my9ku7t9.fsf@eriador.mornfall.net> <4A07202D.1010903@redhat.com>
Message-ID: <874ovsu5ff.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:
> Petr Rockai wrote:
>> Well, I believe the use-case is that when the operation fails halfway (which
>> happens from time to time -- more often than would be comfortable, even), you
>> can clean up by hand, since those offending LVs became visible. If there is a
>> reasonable procedure that the admins can follow to get rid of the junk LVs in
>> those scenarios, I'm fine.
>
> Maybe we should display these "invisible" LVs to user (in reporting commands)
> if no visible LV references them (I mean _mimage, _mlog & Co. devices)
Sounds like a decent solution to me.

> Admin can remove these insvible LV even now (lvremove works), but must
> run "lvs -a" to found them first...
Ok.

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


