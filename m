From: Petr Rockai <prockai@redhat.com>
Date: Fri, 05 Jun 2009 20:52:36 +0200
Subject: [PATCH] Fix double releasing of vg when repairing of vg is requested
In-Reply-To: <4A291EDC.4060300@redhat.com> (Milan Broz's message of "Fri, 05
	Jun 2009 15:34:20 +0200")
References: <4A291EDC.4060300@redhat.com>
Message-ID: <873aaetswb.fsf@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:
> [maybe this somehow collide with proposed vg_read changes,
> but this is serious bug which should be fixed asap...]
Yes, it does collide with vg_read changes, and it also duplicates one of the
patches that already unifies the recovery process. There are other crash bugs
waiting for the vg_read patches to be applied, so maybe it would be best to get
the vg_read patches applied, then...

See also this message:

Subject: Re: [lvm-devel][PATCH] Fix segfault when using vgsplit in stacked environment
Message-ID: <87bpt211a3.fsf@eriador.mornfall.net>

which has a patch that fixes a vgsplit segfault that needs new vg_read.

If there's no better interim fix though and this is really urgent, I guess that
vg_read patches will have to give way. I would however ask that this patch be
reverted before applying vg_read bits, because I have rewritten and rebased
vg_read more than enough times already...

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


