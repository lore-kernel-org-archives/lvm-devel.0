From: Petr Rockai <prockai@redhat.com>
Date: Mon, 05 May 2008 16:15:05 +0200
Subject: [PATCH] partial metadata handling
In-Reply-To: <87skwx64qq.fsf@eriador.mornfall.net> (Petr Rockai's message of
	"Mon, 05 May 2008 01:15:09 +0200")
References: <87skwx64qq.fsf@eriador.mornfall.net>
Message-ID: <87hcdcbzx2.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi again...

Petr Rockai <prockai@redhat.com> writes:
> - the obvious candidate for handles_partial right now is vgreduce
>   --removemissing, but see the next patch for more tool changes
Now that is an obvious nonsense, since --removemissing always writes out
consistent, non-partial metadata, so no need for handles_partial. Sorry for the
confusion. What I meant is that it can work with partial VGs despite that flag
(but the result is a consistent, complete VG).

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


