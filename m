From: Petr Rockai <prockai@redhat.com>
Date: Tue, 26 May 2009 19:26:16 +0200
Subject: [PATCH] Fix convert polling to ignore LV with different UUID.
In-Reply-To: <4A1BED4D.50401@redhat.com> (Milan Broz's message of "Tue, 26 May
	2009 15:23:25 +0200")
References: <4A1BED4D.50401@redhat.com>
Message-ID: <87ab4zzsg7.fsf@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:
> Fix convert polling to ignore LV with different UUID.
>
> When mirror convert polling is started (mainly as backgound process,
> in lvchange -a y or in lvconvert itself) it tries to read VG
> and LV identified by its name.
>
> Unfortunatelly, the VG can have already different LV under the same name,
> and various more or less funny things can happen (note that 
> _finish_lvconvert_mirror suspends the volume for example).
[snip]

> Signed-off-by: Milan Broz <mbroz@redhat.com>
Acked-By: Petr Rockai <prockai@redhat.com>


-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


