From: Petr Rockai <prockai@redhat.com>
Date: Mon, 24 Jan 2011 01:11:12 +0100
Subject: liblvm Python/C extension (Python Liblvm)
In-Reply-To: <1295527769.24069.31.camel@ljonsson.local> ("Lars
	=?utf-8?B?U2rDtnN0csO2bSIncw==?=
	message of "Thu, 20 Jan 2011 13:49:29 +0100")
References: <1295527769.24069.31.camel@ljonsson.local>
Message-ID: <87oc77tb33.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Lars Sj?str?m <lars.sjostrom@redhat.com> writes:
> I was missing a proper LVM2 interface to Python so I decided to write
> one my self! I have wrapped all the liblvm C APIs (excluding the new
> APIs committed in Dec). Doc strings are still missing, as well as proper
> setup.py build env, so consider it as work in progress.
>
> This might also be interesting to other projects like Anaconda for
> example.
>
> I would love to get your feedback on it!

I am not a python guy myself, but I definitely welcome this. On the
other hand, as Zden?k points out, this does have some issues. I also
think Anaconda folks have refused to use liblvm as far as there are no
python bindings (and they are not interested in binding to the C API
themselves). Hence, I suppose they are going to be interested indeed.

Nevertheless, there's another significant issue, and that is
maintenance. I can't commit to maintaining python bindings, since I have
responsibilities besides liblvm and I am a part-timer on LVM -- which
doesn't exactly leave much space for python (which would necessarily
include a lot of learning).

I'll try to talk with the rest of the team about how to best approach
this. There might be someone with the required python (and python
binding) skills and enough time. Alternatively, do you think you could
take the responsibility for the bindings yourself? As far as I recall,
there was talk of shipping python bindings (provided there were any, but
you obviously have some now) with the rest of LVM source (although I
have no idea what technical implications this may have for building
packages).

Yours,
   Petr


