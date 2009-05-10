From: Petr Rockai <prockai@redhat.com>
Date: Sun, 10 May 2009 20:33:22 +0200
Subject: [PATCH 2/7] Never set mirror log and images directly visible in metadata.
In-Reply-To: <a3d0392fa15ad5ecbc874cb5419a0177011655ed.1241620083.git.mbroz@redhat.com>
	(Milan Broz's message of "Wed, 6 May 2009 16:42:59 +0200")
References: <cover.1241620083.git.mbroz@redhat.com>
	<cover.1241620083.git.mbroz@redhat.com>
	<a3d0392fa15ad5ecbc874cb5419a0177011655ed.1241620083.git.mbroz@redhat.com>
Message-ID: <87my9ku7t9.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:
> Mirror creation and conversion force set mirror log and images
> to be visible. This can violate VG max_lv restriction on LV.
>
> There is no need to set these volumes visible, even during
> mirror images conversion.
Well, I believe the use-case is that when the operation fails halfway (which
happens from time to time -- more often than would be comfortable, even), you
can clean up by hand, since those offending LVs became visible. If there is a
reasonable procedure that the admins can follow to get rid of the junk LVs in
those scenarios, I'm fine.

(The whole non-atomicity of those mirror operation is very unfortunate for
other reasons, but I didn't yet have time to investigate how hard it would be
to make those really atomic.)

Other than that, I have reviewed the patch, and it does what the description
advertises, so (bar the above issue) it is good to go, IMHO.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


