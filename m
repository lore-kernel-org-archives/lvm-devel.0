From: Milan Broz <mbroz@redhat.com>
Date: Fri, 17 Jul 2009 09:43:56 +0200
Subject: Re: [PATCH 2/6] Add devices/data_alignment_offset_detection to lvm.conf.
In-Reply-To: <20090716211557.GA9913@redhat.com>
References: <1247515882-13736-1-git-send-email-snitzer@redhat.com>
	<1247515882-13736-3-git-send-email-snitzer@redhat.com>
	<4A5F75CC.8060203@redhat.com> <20090716211557.GA9913@redhat.com>
Message-ID: <4A602BBC.4060506@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Mike Snitzer wrote:
> On Thu, Jul 16 2009 at  2:47pm -0400,
> Milan Broz <mbroz@redhat.com> wrote:
> I'll be sure to cast all MAJOR() and MINOR() calls when used with
> dm_snprintf().  Would still like to understand how not using a cast gets
> us into trouble... but that is for when I get back from vacation ;)

That's clear, we have compatibility macros for MAJOR defined,
on linux it is defined:

#  define MAJOR(dev)    ((dev & 0xfff00) >> 8)

printf %d expect on 32bit int (4 bytes) but MAJOR(dev) is long (8 bytes) here.

On x86_64 it is the same size, so it works.

Just use retype here...

Milan


