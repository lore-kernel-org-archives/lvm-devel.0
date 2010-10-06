From: Petr Rockai <prockai@redhat.com>
Date: Wed, 06 Oct 2010 17:04:31 +0200
Subject: [PATCH 1/6] Fix compiler warning about strict-aliasing break
In-Reply-To: <ab4d6f7b0113a9596c9c691c6f7b1b45f6645dfb.1278505444.git.zkabelac@redhat.com>
	(Zdenek Kabelac's message of "Wed, 7 Jul 2010 14:29:31 +0200")
References: <cover.1278505444.git.zkabelac@redhat.com>
	<cover.1278505444.git.zkabelac@redhat.com>
	<ab4d6f7b0113a9596c9c691c6f7b1b45f6645dfb.1278505444.git.zkabelac@redhat.com>
Message-ID: <871v83l5vk.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Zdenek Kabelac <zkabelac@redhat.com> writes:

> This patch not really tested - and just show a possible solution
> for strict-alliasing error.
>
> So patch is just a proposal of one of many solution.

The patch looks OK, the code is actually cleaner that way. You can also
drop PART_MAGIC_OFFSET which is no longer used (I have checked that it
is indeed PART_OFFSET + 4*sizeof(struct partition)).

I believe the code is equivalent to what was there before. Nevertheless,
a regression test that would cover this area would be more than welcome.

Reviewed-By: Petr Rockai <prockai@redhat.com>

Yours,
  Petr.


