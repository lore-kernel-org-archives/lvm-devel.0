From: Petr Rockai <prockai@redhat.com>
Date: Wed, 08 Apr 2009 01:12:22 +0200
Subject: [PATCH 3/6] vg mempool: fix activation code
In-Reply-To: <49D9BE29.8030002@redhat.com> (Milan Broz's message of "Mon, 06
	Apr 2009 10:32:41 +0200")
References: <49D9BE29.8030002@redhat.com>
Message-ID: <87ws9w9hyh.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:
> Properly release VG memory pool in activation code and clvmd.
>
> Signed-off-by: Milan Broz <mbroz@redhat.com>
Acked-By: Petr Ro?kai <prockai@redhat.com>

No particular comments. Lots of code path shuffling, I have read through all of
it and I believe it's all equivalent, plus it calls vg_release when needed, as
advertised.

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


