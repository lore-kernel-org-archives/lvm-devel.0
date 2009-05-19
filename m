From: Petr Rockai <prockai@redhat.com>
Date: Tue, 19 May 2009 07:53:39 +0200
Subject: [PATCH] vgcfgbackup: do not produce corrupted metadata if PVs are missing
In-Reply-To: <4A0D7D6F.4020103@redhat.com> (Milan Broz's message of "Fri, 15
	May 2009 16:34:23 +0200")
References: <4A0D7D6F.4020103@redhat.com>
Message-ID: <87ws8dbpuk.fsf@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:
> Currently code uses pv_dev_name() for hash when getting internal
> "pvX" name.
>
> This produce corrupted metadata if PVs are missing, pv->dev
> is NULL and all these missing devices returns one name
> (using "unknown device" for all missing devices as hash key).
Good catch. Patch looks good (and comes with a test).

> Signed-off-by: Milan Broz <mbroz@redhat.com>
Acked-By: Petr Rockai <prockai@redhat.com>

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


